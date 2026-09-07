import Component from "@glimmer/component";
import UserLink from "discourse/components/user-link";
import avatar from "discourse/helpers/avatar";
import formatDate from "discourse/helpers/format-date";
import { prioritizeNameInUx } from "discourse/lib/settings";

export default class TopicOp extends Component {
  get creatorName() {
    const creator = this.args.topic.creator;

    if (prioritizeNameInUx(creator?.name)) {
      return creator.name;
    }

    return creator?.username;
  }

  <template>
    <div class="topic-card__op">
      <UserLink @user={{@topic.creator}}>
        {{avatar @topic.creator imageSize="tiny"}}
        <span class="username">
          {{this.creatorName}}
        </span>
      </UserLink>

      {{#if settings.show_publish_date}}
        <span class="topic-card__publish-date">
          {{formatDate @topic.createdAt format="medium-with-ago"}}
        </span>
      {{/if}}
    </div>
  </template>
}
