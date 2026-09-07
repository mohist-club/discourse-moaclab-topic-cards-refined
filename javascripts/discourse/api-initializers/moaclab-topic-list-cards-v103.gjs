import { apiInitializer } from "discourse/lib/api";
import { wantsNewWindow } from "discourse/lib/intercept-click";
import MoaclabHighContextCard from "../components/moaclab-high-context-card-v104";

const MoaclabCardHeader = <template>
  <th class="topic-list-data moaclab-topic-card-header"></th>
</template>;

export default apiInitializer((api) => {
  const site = api.container.lookup("service:site");
  const router = api.container.lookup("service:router");

  function enableCards() {
    if (router.currentRouteName === "topic.fromParamsNear") {
      return settings.show_for_suggested_topics;
    }

    if (settings.show_on_categories?.length === 0) {
      return true;
    }

    const currentCat = router.currentRoute?.attributes?.category?.id;

    if (currentCat === undefined) {
      return false;
    }

    const categoryIds = settings.show_on_categories?.split("|").map(Number);

    return categoryIds.includes(currentCat);
  }

  api.registerValueTransformer(
    "topic-list-class",
    ({ value: additionalClasses }) => {
      if (enableCards()) {
        additionalClasses.push("topic-cards-list");
        additionalClasses.push("moaclab-topic-cards-v111");
        additionalClasses.push(
          `topic-cards-layout--${settings.card_layout || "grid"}`
        );
      }

      return additionalClasses;
    }
  );

  const classNames = ["topic-card"];

  if (settings.set_card_max_height) {
    classNames.push("has-max-height");
  }

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value: additionalClasses }) => {
      if (enableCards()) {
        return [...additionalClasses, ...classNames];
      } else {
        return additionalClasses;
      }
    }
  );

  api.registerValueTransformer("topic-list-item-mobile-layout", ({ value }) => {
    if (enableCards()) {
      return false;
    }

    return value;
  });

  api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
    if (enableCards()) {
      columns.delete("high-context-card");
      columns.delete("topic");
      columns.delete("posters");
      columns.delete("replies");
      columns.delete("views");
      columns.delete("activity");
      columns.delete("tags-mobile");

      columns.add("moaclab-card", {
        header: MoaclabCardHeader,
        item: MoaclabHighContextCard,
      });
    }

    return columns;
  });

  api.registerBehaviorTransformer(
    "topic-list-item-click",
    ({ context, next }) => {
      if (enableCards()) {
        const targetElement = context.event.target;
        const topic = context.topic;

        if (targetElement?.closest?.("a, button, input, select, textarea")) {
          return next();
        }

        const clickTargets = [
          "topic-list-data",
          "link-bottom-line",
          "topic-list-item",
          "topic-card__excerpt",
          "topic-card__excerpt-text",
          "topic-card__metadata",
          "topic-card__likes",
          "topic-card__op",
          "moaclab-topic-card__body",
          "moaclab-topic-card__shell",
          "moaclab-topic-card__excerpt",
          "moaclab-topic-card__footer",
        ];

        if (site.mobileView) {
          clickTargets.push("topic-item-metadata");
        }

        if (clickTargets.some((t) => targetElement?.closest?.(`.${t}`))) {
          if (wantsNewWindow(context.event)) {
            return true;
          }

          context.event.preventDefault();

          return context.navigateToTopic(topic, topic.lastUnreadUrl);
        }
      }

      next();
    }
  );
});
