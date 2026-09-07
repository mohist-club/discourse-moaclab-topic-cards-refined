import Component from "@glimmer/component";
import ActivityCell from "discourse/components/topic-list/item/activity-cell";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import LikeToggle from "./moaclab-like-toggle-v103";

export default class TopicMetadata extends Component {
  get replyCount() {
    return Math.max((this.args.topic.posts_count ?? 1) - 1, 0);
  }

  <template>
    <div class="topic-card__metadata">
      <div class="right-aligned">
        <table class="topic-card__stats">
          <tbody>
            <tr>
              {{#if settings.show_views}}
                <td class="num topic-list-data topic-card__views">
                  {{icon "eye"}}
                  {{number @topic.views}}
                </td>
              {{/if}}

              {{#if settings.show_likes}}
                <td class="num topic-list-data topic-card__likes">
                  <LikeToggle @topic={{@topic}} />
                </td>
              {{/if}}

              {{#if settings.show_reply_count}}
                <td class="num topic-list-data topic-card__replies">
                  {{icon "comment"}}
                  {{number this.replyCount}}
                </td>
              {{/if}}

              {{#if settings.show_activity}}
                <ActivityCell @topic={{@topic}} />
              {{/if}}
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </template>
}
