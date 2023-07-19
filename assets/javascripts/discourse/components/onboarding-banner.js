import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import PostCooked from "discourse/widgets/post-cooked";
import { action } from "@ember/object";

export default class OnboardingBanner extends Component {
  @service router;
  @service siteSettings;

  @tracked cooked;
  @tracked maxExpired = false;
  @tracked isLoading = true;
  @tracked dismissed = false;

  constructor() {
    super(...arguments);
    const date = Date.now();

    let storageObject;
    let storedTopicId;

    let localExpired;
    let maxExpired;

    let getLocal = localStorage.getItem("onboarding_topic");

    if (getLocal) {
      storageObject = JSON.parse(getLocal);
      storedTopicId = storageObject.storedTopicId;

      let cached = storageObject.timestamp;
      let firstSeen = storageObject.firstSeen;

      let expiration = 21600 * 1000; // 6 hours
      let maxAge = 604800 * 1000; // 7 days

      if (date - cached > expiration) {
        localExpired = true;
      }

      if (date - firstSeen > maxAge) {
        maxExpired = true;
      }
    }

    if (maxExpired) {
      this.isLoading = false;
      this.maxExpired = true;
      return;
    }

    const topicId = this.siteSettings.discourse_onboarding_banner_topic_id;

    if (
      !getLocal ||
      localExpired ||
      (storedTopicId && topicId !== storedTopicId)
      // if no local storage, or if storage is expired, or if a different topic is set in the setting
    ) {
      this.loadContent(topicId, date, storageObject);
    } else {
      if (storageObject) {
        this.cooked = storageObject.cookedContent;
        this.isLoading = false;
      }
    }
  }

  async loadContent(topicId, date, storageObject) {
    try {
      const response = await ajax(`/discourse-onboarding-banner/content.json`);
      // get the topic
      let dataObject = {
        storedTopicId: topicId,
        timestamp: date,
        firstSeen: storageObject ? storageObject.firstSeen : date,
      };

      if (response.cooked) {
        const regex = /\{\%sitename\}/gm;

        let firstPost = response.cooked;
        let replacedPost = firstPost.replace(regex, this.siteSettings.title); // replace {%sitename} with site name

        let cachedTopic = new PostCooked({
          cooked: replacedPost,
        });
        dataObject.cookedContent = cachedTopic.attrs.cooked;
        this.cooked = cachedTopic.attrs.cooked;
      }

      localStorage.setItem("onboarding_topic", JSON.stringify(dataObject));
    } catch {
      this.cooked = null;
    } finally {
      this.isLoading = false;
    }
  }

  get visible() {
    return (
      !this.dismissed && !this.isLoading && !this.maxExpired && this.cooked
    );
  }

  @action
  async dismissOnboarding() {
    let storageObject = {};
    let data = {};
    let getLocal = localStorage.getItem("onboarding_topic");
    if (getLocal) {
      storageObject = JSON.parse(getLocal);
      data = { topic_id: storageObject.storedTopicId };
    }

    try {
      await ajax("/discourse-onboarding-banner/dismiss.json", {
        type: "PUT",
        data,
      });
    } finally {
      this.dismissed = true;

      if (getLocal) {
        storageObject = JSON.parse(getLocal);
        delete storageObject.cookedContent;
        localStorage.setItem("onboarding_topic", JSON.stringify(storageObject));
      }
    }
  }
}
