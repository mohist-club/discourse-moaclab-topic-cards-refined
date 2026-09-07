import Component from "@glimmer/component";
import { computed } from "@ember/object";

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

export default class TopicThumbnail extends Component {
  get topic() {
    return this.args.topic || this.args.outletArgs.topic;
  }

  @computed("topic.thumbnails")
  get hasThumbnail() {
    return Array.isArray(this.topic.thumbnails) && this.topic.thumbnails.length;
  }

  @computed("topic.thumbnails")
  get srcSet() {
    return this.responsiveThumbnails
      .map((thumbnail) => `${thumbnail.url} ${thumbnail.width}w`)
      .join(",");
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
  get responsiveThumbnails() {
    const byWidth = new Map();

    (this.topic.thumbnails || []).forEach((thumbnail) => {
      const width = Number(thumbnail.width || thumbnail.max_width);

      if (thumbnail.url && Number.isFinite(width) && width > 0) {
        byWidth.set(width, thumbnail);
      }
    });

    return [...byWidth.entries()]
      .sort(([a], [b]) => a - b)
      .map(([width, thumbnail]) => ({ ...thumbnail, width }));
  }

  @computed("topic.thumbnails")
  get fallbackSrc() {
    const targetWidth = settings.card_layout === "horizontal" ? 400 : 800;
    const bestFit = this.responsiveThumbnails.find(
      (thumbnail) => thumbnail.width >= targetWidth
    );

    return bestFit?.url || this.responsiveThumbnails.at(-1)?.url || "";
  }

  get imageSizes() {
    return settings.card_layout === "horizontal"
      ? "(max-width: 760px) 100vw, 300px"
      : "(max-width: 760px) 100vw, 756px";
  }

  get url() {
    return this.topic.linked_post_number
      ? this.topic.urlForPostNumber(this.topic.linked_post_number)
      : this.topic.get("lastUnreadUrl");
  }

  get displayImages() {
    return this.fallbackSrc ? [absoluteUrl(this.fallbackSrc)] : [];
  }

  get hasMedia() {
    return this.displayImages.length > 0;
  }

  get currentImageUrl() {
    return this.displayImages[0] || this.fallbackSrc;
  }

  get currentSrcSet() {
    return this.srcSet;
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
            sizes={{this.imageSizes}}
            width={{this.width}}
            height={{this.height}}
            alt={{this.topic.title}}
            loading="lazy"
            decoding="async"
          />
        {{/if}}
      </a>
    </div>
  </template>
}
