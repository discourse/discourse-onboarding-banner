import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Discourse Onboarding Banner", function (needs) {
  needs.user({ show_onboarding_banner: true });
  needs.settings({
    discourse_onboarding_banner_enabled: true,
    discourse_onboarding_banner_topic_id: 24,
  });

  needs.pretender((server, helper) => {
    server.get("/discourse-onboarding-banner/content.json", () => {
      return helper.response({
        topic_id: 24,
        cooked: "banner content goes here",
      });
    });

    server.put("/discourse-onboarding-banner/dismiss.json", () => {
      return helper.response({});
    });
  });

  test("Onboarding banner is shown and can be dismissed", async function (assert) {
    await visit("/");
    assert
      .dom(".onboarding-banner-content")
      .includesText(
        "banner content goes here",
        "it shows the onboarding banner"
      );

    await click(".onboarding-banner-content .dismiss-banner");
    assert
      .dom(".onboarding-banner-content")
      .doesNotExist("it hides the onboarding banner");
  });
});
