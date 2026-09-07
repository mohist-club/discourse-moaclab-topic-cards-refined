import Component from "@glimmer/component";
import dirSpan from "discourse/helpers/dir-span";

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

export default class TopicExcerpt extends Component {
  get excerpt() {
    return cleanTopicExcerpt(this.args.topic.escapedExcerpt || "");
  }

  <template>
    <div class="topic-card__excerpt">
      <div class="topic-card__excerpt-text">
        {{dirSpan this.excerpt htmlSafe="true"}}
      </div>
    </div>
  </template>
}
