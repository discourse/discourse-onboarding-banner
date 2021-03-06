import {
  acceptance,
  exists,
  visible,
} from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { click, visit } from "@ember/test-helpers";

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

  test("DiscourseOnboardingBanner is shown and can be dismissed", async (assert) => {
    await visit("/");
    assert.ok(
      exists(".onboarding-banner-content"),
      "it shows the DiscourseOnboardingBanner"
    );

    await click(".onboarding-banner-content .dismiss-banner");
    assert.ok(
      !visible(".onboarding-banner-content"),
      "it hides the DiscourseOnboardingBanner"
    );
  });
});
