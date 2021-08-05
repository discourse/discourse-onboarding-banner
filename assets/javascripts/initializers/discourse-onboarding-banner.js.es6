import { withPluginApi } from "discourse/lib/plugin-api";

function initializeDiscourseOnboardingBanner(api) {
  // https://github.com/discourse/discourse/blob/main/app/assets/javascripts/discourse/lib/plugin-api.js.es6
}

export default {
  name: "discourse-onboarding-banner",

  initialize() {
    withPluginApi("0.8.31", initializeDiscourseOnboardingBanner);
  }
};
