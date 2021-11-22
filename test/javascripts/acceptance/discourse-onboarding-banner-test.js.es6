import { acceptance } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";

acceptance("DiscourseOnboardingBanner", function (needs) {
  needs.user();

  test("DiscourseOnboardingBanner works", async assert => {
    await visit("/admin/plugins/discourse-onboarding-banner");

    assert.ok(false, "it shows the DiscourseOnboardingBanner button");
});
