export default {
  shouldRender(args, component) {
    return (
      component.currentUser &&
      component.siteSettings.discourse_onboarding_banner_enabled
    );
  },
};
