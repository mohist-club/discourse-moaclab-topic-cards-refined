import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { computed } from "@ember/object";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";

const TOPIC_GALLERY_CACHE = new Map();

function absoluteUrl(url) {
  if (!url) {
    return "";
  }

  try {
    return new URL(url, window.location.origin).href;
  } catch {
    return "";
  }
}

function imageUrlsFromCooked(cooked = "") {
  const container = document.createElement("div");
  container.innerHTML = cooked;

  return [...container.querySelectorAll("img")]
    .map((image) =>
      absoluteUrl(
        image.dataset.originalSrc ||
          image.dataset.largeSrc ||
          image.currentSrc ||
          image.getAttribute("src")
      )
    )
    .filter(Boolean)
    .filter((url, index, all) => all.indexOf(url) === index);
}

export default class TopicThumbnail extends Component {
  responsiveRatios = [1, 1.5, 2];
  @tracked galleryImages = [];
  @tracked selectedIndex = 0;
  @tracked loadedTopicId = null;

  get topic() {
    return this.args.topic || this.args.outletArgs.topic;
  }

  @computed("topic.thumbnails")
  get hasThumbnail() {
    return Array.isArray(this.topic.thumbnails) && this.topic.thumbnails.length;
  }

  @computed("topic.thumbnails", "displayWidth")
  get srcSet() {
    const srcSetArray = [];

    this.responsiveRatios.forEach((ratio) => {
      const target = ratio * this.displayWidth;
      const match = (this.topic.thumbnails || []).find(
        (t) => t.url && t.max_width === target
      );
      if (match) {
        srcSetArray.push(`${match.url} ${ratio}x`);
      }
    });

    if (srcSetArray.length === 0) {
      srcSetArray.push(`${this.original.url} 1x`);
    }

    return srcSetArray.join(",");
  }

  @computed("topic.thumbnails")
  get original() {
    return this.topic.thumbnails?.[0];
  }

  get width() {
    return this.original?.width || 1200;
  }

  get isLandscape() {
    return this.width >= this.height;
  }

  get height() {
    return this.original?.height || 790;
  }

  @computed("topic.thumbnails")
  get fallbackSrc() {
    const largeEnough = (this.topic.thumbnails || []).filter((t) => {
      if (!t.url) {
        return false;
      }
      return t.max_width > this.displayWidth * this.responsiveRatios.at(-1);
    });

    const largest = largeEnough.at(-1);
    if (largest) {
      return largest.url;
    }

    return this.original?.url || "";
  }

  get url() {
    return this.topic.linked_post_number
      ? this.topic.urlForPostNumber(this.topic.linked_post_number)
      : this.topic.get("lastUnreadUrl");
  }

  get displayImages() {
    this.ensureGalleryLoaded();

    const fallback = this.fallbackSrc ? [absoluteUrl(this.fallbackSrc)] : [];
    return this.galleryImages.length ? this.galleryImages : fallback;
  }

  get hasMedia() {
    return this.displayImages.length > 0;
  }

  get currentImageUrl() {
    return this.displayImages[this.selectedIndex] || this.fallbackSrc;
  }

  get currentSrcSet() {
    return this.hasCarousel ? "" : this.srcSet;
  }

  get hasCarousel() {
    return this.displayImages.length > 1;
  }

  get carouselDots() {
    return this.displayImages.map((image, index) => ({
      image,
      index,
      active: index === this.selectedIndex,
    }));
  }

  ensureGalleryLoaded() {
    const topicId = this.topic?.id;

    if (!topicId || this.loadedTopicId === topicId) {
      return;
    }

    this.loadedTopicId = topicId;

    if (TOPIC_GALLERY_CACHE.has(topicId)) {
      this.galleryImages = TOPIC_GALLERY_CACHE.get(topicId);
      this.selectedIndex = 0;
      return;
    }

    fetch(`/t/${topicId}.json`, {
      credentials: "same-origin",
      headers: { Accept: "application/json" },
    })
      .then((response) => (response.ok ? response.json() : null))
      .then((payload) => {
        const cooked = payload?.post_stream?.posts?.[0]?.cooked || "";
        const images = imageUrlsFromCooked(cooked);

        TOPIC_GALLERY_CACHE.set(topicId, images);

        if (this.loadedTopicId === topicId) {
          this.galleryImages = images;
          this.selectedIndex = 0;
        }
      })
      .catch(() => {
        TOPIC_GALLERY_CACHE.set(topicId, []);
      });
  }

  @action
  previousImage(event) {
    event.preventDefault();
    event.stopPropagation();

    if (!this.hasCarousel) {
      return;
    }

    this.selectedIndex =
      (this.selectedIndex - 1 + this.displayImages.length) %
      this.displayImages.length;
  }

  @action
  nextImage(event) {
    event.preventDefault();
    event.stopPropagation();

    if (!this.hasCarousel) {
      return;
    }

    this.selectedIndex = (this.selectedIndex + 1) % this.displayImages.length;
  }

  @action
  selectImage(event) {
    event.preventDefault();
    event.stopPropagation();

    this.selectedIndex = Number(event.currentTarget.dataset.index || 0);
  }

  <template>
    <div
      class={{if
        this.hasMedia
        "topic-card__thumbnail moaclab-topic-card__media"
        "no-thumbnail moaclab-topic-card__media"
      }}
    >
      <a href={{this.url}}>
        {{#if this.hasMedia}}
          <img
            class="main-thumbnail"
            src={{this.currentImageUrl}}
            srcset={{this.currentSrcSet}}
            width={{this.width}}
            height={{this.height}}
            alt={{this.topic.title}}
            loading="lazy"
          />
        {{/if}}
      </a>
      {{#if this.hasCarousel}}
        <div class="moaclab-topic-card__carousel-controls">
          <button
            type="button"
            class="moaclab-topic-card__carousel-button --prev"
            title="上一张"
            aria-label="上一张"
            {{on "click" this.previousImage}}
          >
            {{icon "chevron-left"}}
          </button>
          <button
            type="button"
            class="moaclab-topic-card__carousel-button --next"
            title="下一张"
            aria-label="下一张"
            {{on "click" this.nextImage}}
          >
            {{icon "chevron-right"}}
          </button>
          <div class="moaclab-topic-card__carousel-dots" aria-hidden="true">
            {{#each this.carouselDots as |dot|}}
              <button
                type="button"
                class={{if dot.active "is-active" ""}}
                data-index={{dot.index}}
                tabindex="-1"
                {{on "click" this.selectImage}}
              ></button>
            {{/each}}
          </div>
        </div>
      {{/if}}
    </div>
  </template>
}
