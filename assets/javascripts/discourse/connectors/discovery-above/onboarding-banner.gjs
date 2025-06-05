import Component from "@ember/component";
import { classNames, tagName } from "@ember-decorators/component";
import OnboardingBanner0 from "../../components/onboarding-banner";

@tagName("div")
@classNames("discovery-above-outlet", "onboarding-banner")
export default class OnboardingBanner extends Component {
  static shouldRender(args, context) {
    return (
      context.currentUser?.show_onboarding_banner &&
      context.siteSettings.discourse_onboarding_banner_enabled
    );
  }

  <template><OnboardingBanner0 /></template>
}
