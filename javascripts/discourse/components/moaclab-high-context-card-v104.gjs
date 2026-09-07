import Component from "@glimmer/component";
import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import formatDate from "discourse/helpers/format-date";
import number from "discourse/helpers/number";
import getURL from "discourse/lib/get-url";
import { prioritizeNameInUx } from "discourse/lib/settings";
import LikeToggle from "./moaclab-like-toggle-v103";
import TopicThumbnail from "./topic-thumbnail";

const READ_MORE_LINK_PATTERN =
  /<a\b[^>]*class=(["'])[^"']*(?:read-more|topic-excerpt-more|excerpt-more)[^"']*\1[^>]*>[\s\S]*?<\/a>\s*$/iu;
const READ_MORE_TEXT_PATTERN =
  /\s*(?:…|&hellip;|\.\.\.)?\s*(?:阅读更多|read more)\s*$/iu;
const MOACLAB_3D_SHORTCODE_PATTERN =
  /\s*(?:\[|&#91;|&lbrack;)moaclab-3d\b[\s\S]*?(?:\]|&#93;|&rbrack;)\s*/giu;

function cleanTopicExcerpt(excerpt = "") {
  return excerpt
    .replace(READ_MORE_LINK_PATTERN, "")
    .replace(READ_MORE_TEXT_PATTERN, "")
    .replace(MOACLAB_3D_SHORTCODE_PATTERN, " ")
    .replace(/\s{2,}/gu, " ")
    .trim();
}

export default class MoaclabHighContextCard extends Component {
  get creatorName() {
    const creator = this.args.topic.creator;
    return prioritizeNameInUx(creator?.name) ? creator.name : creator?.username;
  }

  get excerpt() {
    return cleanTopicExcerpt(
      this.args.topic.escapedExcerpt || this.args.topic.excerpt || ""
    );
  }

  get firstTagData() {
    const tag = this.args.topic.tags?.[0] ?? this.args.topic.tag_names?.[0];

    if (!tag) {
      return undefined;
    }

    const name =
      typeof tag === "string"
        ? tag
        : [tag.name, tag.text, tag.slug].find(
            (candidate) =>
              typeof candidate === "string" &&
              candidate.trim() &&
              candidate !== "[object Object]"
          );

    if (!name) {
      return undefined;
    }

    // A Discourse tag URL uses the slug/name, never the numeric database id.
    const slug =
      typeof tag === "string"
        ? name
        : [tag.slug, tag.name, tag.text].find(
            (candidate) => typeof candidate === "string" && candidate.trim()
          ) || name;

    return {
      name: String(name).trim(),
      slug: String(slug).trim(),
    };
  }

  get firstTag() {
    return this.firstTagData?.name;
  }

  get firstTagUrl() {
    const slug = this.firstTagData?.slug;
    return slug ? getURL(`/tag/${encodeURIComponent(slug)}`) : undefined;
  }

  get communityName() {
    return (
      this.args.topic.category?.name ||
      this.args.topic.category?.slug ||
      this.firstTag ||
      "Moaclab"
    );
  }

  get replyCount() {
    return (
      this.args.topic.replyCount ??
      Math.max((this.args.topic.posts_count ?? 1) - 1, 0)
    );
  }

  <template>
    <td class="moaclab-topic-card__cell">
      <article class="moaclab-topic-card__shell">
        <div class="hc-topic-card moaclab-topic-card__body">
          <div class="link-bottom-line moaclab-topic-card__byline">
            <div class="moaclab-topic-card__author-meta">
              <UserLink @user={{@topic.creator}}>
                {{avatar @topic.creator imageSize="tiny"}}
              </UserLink>
              <UserLink
                @user={{@topic.creator}}
                class="moaclab-topic-card__author-link"
              >
                {{this.creatorName}}
              </UserLink>
              {{#if settings.show_publish_date}}
                <span class="moaclab-topic-card__publish-date">
                  {{formatDate @topic.createdAt format="medium-with-ago"}}
                </span>
              {{/if}}
            </div>

            <a
              class="btn btn-flat btn-icon no-text moaclab-topic-card__more-action"
              href={{@topic.lastUnreadUrl}}
              title="更多"
              aria-label="更多"
            >
              {{icon "ellipsis"}}
            </a>
          </div>

          <div
            class="link-top-line topic-card__title moaclab-topic-card__title"
            role="heading"
            aria-level="2"
          >
            <a
              class="title raw-link raw-topic-link"
              href={{@topic.lastUnreadUrl}}
            >{{@topic.title}}</a>
          </div>

          <TopicThumbnail @topic={{@topic}} />

          <div class="moaclab-topic-card__footer">
            <div class="moaclab-topic-card__taxonomy">
              {{#if this.firstTag}}
                <a class="discourse-tag" href={{this.firstTagUrl}}>
                  <span class="discourse-tag__dot" aria-hidden="true"></span>
                  {{this.firstTag}}
                </a>
              {{/if}}
            </div>

            <div class="moaclab-topic-card__stats">
              {{#if settings.show_likes}}
                <LikeToggle @topic={{@topic}} />
              {{/if}}
              {{#if settings.show_views}}
                <span
                  class="moaclab-topic-card__native-action --views"
                  title="Views"
                >
                  {{icon "eye"}}
                  {{number @topic.views}}
                </span>
              {{/if}}
              {{#if settings.show_reply_count}}
                <a
                  class="btn btn-flat btn-icon-text moaclab-topic-card__native-action --replies"
                  href={{@topic.lastUnreadUrl}}
                  title="评论"
                >
                  {{icon "comment"}}
                  <span>{{number this.replyCount}}</span>
                </a>
              {{/if}}
              {{#if settings.show_activity}}
                <span class="moaclab-topic-card__native-action --activity">
                  {{formatDate @topic.last_posted_at format="medium-with-ago"}}
                </span>
              {{/if}}
            </div>

            <a
              href={{@topic.lastUnreadUrl}}
              class="btn btn-flat btn-icon-text moaclab-topic-card__native-action moaclab-topic-card__share-action"
              title="分享"
            >
              {{icon "share"}}
              <span>Share</span>
            </a>
          </div>
        </div>
      </article>
    </td>
  </template>
}
