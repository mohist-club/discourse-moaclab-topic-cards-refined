# Moaclab Topic Cards

Moaclab visual fork of the official Discourse Topic Cards theme component.
It keeps the upstream data flow, navigation, likes, replies, and infinite topic
loading, while applying the image-led card layout used by the Keycaps category.

## 1.0.67

- Makes `card_layout` functional: `grid` keeps the image-led vertical card and
  `horizontal` uses a compact image-left/content-right desktop layout.
- Makes `set_card_max_height` and `card_max_height` functional by limiting only
  desktop media, never clipping text or actions; mobile remains unrestricted.
- Caches the selected category IDs and prevents duplicate topic-list classes.
- Removes the unused carousel styles and SVG icon registrations.
- Fixes responsive thumbnail selection by emitting width-based `srcset` and
  `sizes`, so browsers can avoid downloading the full original image.

## 1.0.66

- Removes the per-card `/t/{id}.json` gallery requests. Cards now use thumbnail
  data already included in the category topic list, preventing request bursts
  that trigger Discourse's `user_10_secs_limit` and `user_60_secs_limit`.

## Settings

| Setting | Effect |
| --- | --- |
| `card_layout` | `grid` uses an image-led vertical card; `horizontal` uses image-left/content-right on desktop and automatically stacks on mobile. |
| `show_likes` | Shows the current like count and, when allowed by Discourse, the native like action. |
| `show_views` | Shows the topic view count. |
| `show_reply_count` | Shows replies, excluding the opening post. |
| `show_activity` | Shows the latest activity time. |
| `show_publish_date` | Shows the original publication date beside the author. |
| `show_on_homepage` | Enables cards on the main latest, hot, and top discovery routes. |
| `set_card_max_height` | Enables the desktop media-height limit without clipping text or actions. |
| `card_max_height` | Sets that desktop media limit in pixels; ignored when the toggle is off and on mobile. |
| `show_on_categories` | Limits cards to selected categories; an empty selection enables all category lists. |
| `show_for_suggested_topics` | Enables the card renderer for suggested topics. |

## 1.0.11

- Moves the complete phone composition into Discourse's dedicated mobile
  stylesheet so it is applied in mobile view regardless of viewport detection.
- Cancels configured card heights with sufficient specificity and keeps the
  compact title-and-stats row visible below every image.

## 1.0.10

- Fixes the mobile card-height cascade when `set_card_max_height` is enabled.
  Phone cards now always render the complete image, followed by the compact
  title-and-stats row, instead of clipping the text below the image.

## 1.0.9

- Rebuilds phone cards as a dedicated mobile composition: full-width image,
  then one compact row with the title and enabled like/reply/view counters.
- Hides author, publish date, excerpt, and taxonomy on phones to match the
  compact visual reference without affecting desktop layouts.

## 1.0.8

- Refines horizontal cards on phones with a compact image, denser typography,
  and a footer that stays visible.
- Normalizes serialized tag values and links the first tag to its native
  Discourse tag page.

## Defaults

- Enabled for category ID `8` (`/c/keycaps/8`).
- `card_layout: grid`: three columns on wide screens, two on compact desktop,
  one on mobile. This is the default and is recommended for the Keycaps library.
- `card_layout: horizontal`: one compact row per topic with the image on the
  left and title, excerpt, taxonomy, likes, and replies on the right.
- Horizontal cards preserve the taxonomy and stats row at a 200px configured
  card height by using a compact text rhythm instead of clipping metadata.
- One-line topic title without a visible ellipsis glyph.
- Category and the first topic tag only.
- Likes and replies share the bottom-right metadata row.
- No extra topic or category API requests are made by this component.
- Horizontal cards switch to a full-width image-above-content layout on mobile.

All upstream settings remain available in the Discourse theme-component UI.

## Layout setting

Open **Admin → Customize → Themes → Components → Moaclab Topic Cards →
Settings** and choose `card_layout`:

- `grid` for visual browsing and image-led categories.
- `horizontal` when summaries and comparison scanning matter more than density.

## Installation

### GitHub install

1. Open **Admin → Customize → Themes → Install → From a git repository**.
2. Paste the public repository URL for this component.
3. Add it to the active Moaclab theme.
4. Disable the unmodified Topic Cards component on the same theme so only one
   Topic Cards implementation is active.
5. For later changes, open this component in Discourse admin and run
   **Check for Updates / Update to Latest**.

### Manual install

1. Upload this directory or its ZIP as a **theme component**.
2. Add it to the active Moaclab theme.
3. Disable the unmodified Topic Cards component on the same theme so only one
   Topic Cards implementation is active.
4. Use Moaclab Community `3.5.8-meta.11` or newer. That version disables the
   theme's legacy keycap-card injector whenever the official card DOM is active.

## Upstream

- Source: https://github.com/discourse/discourse-topic-cards
- Documentation: https://meta.discourse.org/t/discourse-topic-cards/296048
- License: GPL-2.0-or-later (see `LICENSE`)
