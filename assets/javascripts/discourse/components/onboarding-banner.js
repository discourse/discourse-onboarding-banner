import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import PostCooked from "discourse/widgets/post-cooked";
import { action } from "@ember/object";
import discourseComputed from "discourse-common/utils/decorators";

export default Component.extend({
  classNameBindings: ["onboarding-banner"],
  router: service(),
  cooked: null,
  maxExpired: false,
  isLoading: true,

  init() {
    this._super(...arguments);
    const date = Date.now();

    let topicId = this.siteSettings.discourse_onboarding_banner_topic_id;

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
      this.set("isLoading", false);
      this.set("maxExpired", true);
      return;
    }

    if (
      !getLocal ||
      localExpired ||
      (storedTopicId && topicId !== storedTopicId)
      // if no local storage, or if storage is expired, or if a different topic is set in the setting
    ) {
      ajax(`/discourse-onboarding-banner/content.json`)
        .then((response) => {
          // get the topic
          let dataObject = {
            storedTopicId: topicId,
            timestamp: date,
            firstSeen: storageObject ? storageObject.firstSeen : date,
          };

          if (response.cooked) {
            const regex = /\{\%sitename\}/gm;

            let firstPost = response.cooked;
            let replacedPost = firstPost.replace(
              regex,
              this.siteSettings.title
            ); // replace {%sitename} with site name

            let cachedTopic = new PostCooked({
              cooked: replacedPost,
            });
            dataObject.cookedContent = cachedTopic.attrs.cooked;
            this.set("cooked", cachedTopic.attrs.cooked);
          }

          localStorage.setItem("onboarding_topic", JSON.stringify(dataObject));
        })
        .catch(() => {
          this.set("cooked", null);
        })
        .finally(() => {
          this.set("isLoading", false);
        });
    } else {
      if (storageObject) {
        this.set("cooked", storageObject.cookedContent);
        this.set("isLoading", false);
      }
    }
  },

  @action
  dismissOnboarding() {
    let storageObject = {};
    let data = {};
    let getLocal = localStorage.getItem("onboarding_topic");
    if (getLocal) {
      storageObject = JSON.parse(getLocal);
      data = { topic_id: storageObject.storedTopicId };
    }

    ajax("/discourse-onboarding-banner/dismiss.json", {
      type: "PUT",
      data,
    }).finally(() => {
      document.querySelector("div.onboarding-banner").style.display = "none";

      if (getLocal) {
        storageObject = JSON.parse(getLocal);
        delete storageObject.cookedContent;
        localStorage.setItem("onboarding_topic", JSON.stringify(storageObject));
      }
    });
  },

  @discourseComputed("isLoading", "maxExpired", "cooked")
  shouldHideBanner(isLoading, maxExpired, cooked) {
    return isLoading || maxExpired || !cooked;
  },
});
