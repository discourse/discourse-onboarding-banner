import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("DiscourseOnboardingBanner", { loggedIn: true });

test("DiscourseOnboardingBanner works", async assert => {
  await visit("/admin/plugins/discourse-onboarding-banner");

  assert.ok(false, "it shows the DiscourseOnboardingBanner button");
});
