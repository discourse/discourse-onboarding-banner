import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import DecoratedHtml from "discourse/components/decorated-html";
import htmlSafe from "discourse/helpers/html-safe";
import { ajax } from "discourse/lib/ajax";
import { bind } from "discourse/lib/decorators";

export default class OnboardingBanner extends Component {
  @service appEvents;
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

        dataObject.cookedContent = replacedPost;
        this.cooked = replacedPost;
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

  @bind
  decorateContent(element, helper) {
    this.appEvents.trigger(
      "decorate-non-stream-cooked-element",
      element,
      helper
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

  <template>
    {{#if this.visible}}
      <div class="onboarding-banner">
        <div class="onboarding-banner-content">
          <DecoratedHtml
            @html={{htmlSafe this.cooked}}
            @decorate={{this.decorateContent}}
            @id="onboarding-banner-content"
          />
          <DButton
            class="dismiss-banner"
            @icon="xmark"
            @action={{this.dismissOnboarding}}
          />
        </div>
      </div>
    {{/if}}
  </template>
}
