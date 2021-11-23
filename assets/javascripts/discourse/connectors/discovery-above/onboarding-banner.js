export default {
  shouldRender(args, component) {
    return (
      component.currentUser?.show_onboarding_banner &&
      component.siteSettings.discourse_onboarding_banner_enabled
    );
  },
};
