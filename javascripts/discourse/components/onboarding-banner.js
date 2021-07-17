import discourseComputed from "discourse-common/utils/decorators";
import Component from "@ember/component";
import { inject as service } from "@ember/service";
import { defaultHomepage } from "discourse/lib/utilities";
import { ajax } from "discourse/lib/ajax";
import PostCooked from "discourse/widgets/post-cooked";
import { emojiUnescape, sanitize } from "discourse/lib/text";

export default Component.extend({
  classNameBindings: ["onboarding-banner"],
  router: service(),
  cooked: null,
  maxExpired: false,

  init() {
    this._super(...arguments);
    const date = Date.now();
    let topicId = 38;

    let storageObject;
    let storedTopic;

    let localExpired;
    let maxExpired;

    let dismissed = false;

    let getLocal = localStorage.getItem("onboarding_topic");

    if (getLocal) {
      storageObject = JSON.parse(getLocal);
      dismissed = storageObject.dismissed;

      if (!dismissed) {
        storedTopic = storageObject.topic_id;

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
    }

    if (maxExpired || dismissed) {
      this.set("isLoading", false);
      this.set("maxExpired", true);
      return;
    } else if (
      !getLocal ||
      localExpired ||
      (storedTopic && topicId !== storedTopic)
      // if no local storage, or if storage is expired, or if the topic has been changed
    ) {
      ajax(`/t/${topicId}.json`).then((response) => {
        // get the topic

        const regex = /\{\%sitename\}/gm;

        let firstPost = response.post_stream.posts[0].cooked;
        let replacedPost = firstPost.replace(regex, this.siteSettings.title);

        let cachedTopic = new PostCooked({
          cooked: replacedPost,
        });
        let dataObject = {
          onboarding_topic: cachedTopic.attrs.cooked,
          topic_id: topicId,
          timestamp: date,
          firstSeen: storageObject ? storageObject.firstSeen : date,
          dismissed: false,
        };

        localStorage.setItem("onboarding_topic", JSON.stringify(dataObject));
        this.set("cooked", cachedTopic.attrs.cooked);
        this.set("isLoading", false);
      });
    } else {
      if (storageObject) {
        this.set("cooked", storageObject.onboarding_topic);
        this.set("isLoading", false);
      }
    }
  },

  @discourseComputed("router.currentRoute", "router.currentRouteName")
  showHere(currentRoute, currentRouteName) {
    if (currentRoute) {
      return currentRouteName == `discovery.${defaultHomepage()}`;
    }
  },

  actions: {
    dismissOnboarding() {
      let dataObject = {
        dismissed: true,
      };
      document.querySelector("div.onboarding-banner").style.display = "none";
      localStorage.setItem("onboarding_topic", JSON.stringify(dataObject));
    },
  },
});
