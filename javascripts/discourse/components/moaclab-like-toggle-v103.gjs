import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import concatClass from "discourse/helpers/concat-class";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import { ajax } from "discourse/lib/ajax";

export default class LikeToggle extends Component {
  @service dialog;

  @tracked liked = !!this.args.topic.op_liked;
  @tracked likeCount = this.initialLikeCount;
  @tracked loading = false;

  get initialLikeCount() {
    return this.args.topic.op_like_count ?? this.args.topic.like_count ?? 0;
  }

  get firstPostId() {
    return this.args.topic.first_post_id || false;
  }

  get canLike() {
    return !!this.firstPostId && !!this.args.topic.op_can_like;
  }

  get isDisabled() {
    return !this.canLike || this.loading;
  }

  get likeTitle() {
    if (!this.canLike) {
      return "无法点赞";
    }

    return "点赞";
  }

  @action
  async toggleLike(event) {
    event.preventDefault();
    event.stopPropagation();

    if (!this.canLike || this.loading) {
      return;
    }

    const previous = {
      liked: this.liked,
      likeCount: this.likeCount,
    };

    this.loading = true;
    this.liked = !previous.liked;
    this.likeCount = Math.max(this.likeCount + (previous.liked ? -1 : 1), 0);

    try {
      await this.toggleLikeRequest();
    } catch {
      this.liked = previous.liked;
      this.likeCount = previous.likeCount;
      this.dialog.alert(
        this.liked ? "取消点赞失败，请稍后再试。" : "点赞失败，请稍后再试。"
      );
    } finally {
      this.loading = false;
    }
  }

  async toggleLikeRequest() {
    if (this.liked) {
      return ajax("/post_actions", {
        type: "POST",
        data: { id: this.firstPostId, post_action_type_id: 2 },
      });
    }

    return ajax(`/post_actions/${this.firstPostId}`, {
      type: "DELETE",
      data: { post_action_type_id: 2 },
    });
  }

  <template>
    <span class="topic__like-wrapper">
      <button
        type="button"
        disabled={{this.isDisabled}}
        title={{this.likeTitle}}
        aria-label="点赞"
        aria-pressed={{this.liked}}
        aria-busy={{this.loading}}
        class={{concatClass
          (if this.liked "--liked")
          "btn btn-flat btn-icon-text topic__like-button"
        }}
        {{on "click" this.toggleLike}}
      >
        {{icon "arrow-up"}}
        <span class="topic__like-count">{{number this.likeCount}}</span>
      </button>
    </span>
  </template>
}
