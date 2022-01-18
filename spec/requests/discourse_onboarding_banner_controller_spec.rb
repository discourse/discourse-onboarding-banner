# frozen_string_literal: true

require 'rails_helper'

describe DiscourseOnboardingBanner::DiscourseOnboardingBannerController do
  context 'logged out' do
    it 'returns error getting content' do
      get '/discourse-onboarding-banner/content.json'
      expect(response.status).to eq(404)
    end

    it 'returns error dismissing content' do
      put '/discourse-onboarding-banner/dismiss.json'
      expect(response.status).to eq(404)
    end
  end

  context 'logged in' do
    fab!(:user) { Fabricate(:user) }

    before do
      sign_in(user)
    end

    context 'plugin disabled' do
      before do
        SiteSetting.discourse_onboarding_banner_enabled = false
      end

      it 'returns error when getting content' do
        get '/discourse-onboarding-banner/content.json'
        expect(response.status).to eq(404)
      end

      it 'returns error dismissing content' do
        put '/discourse-onboarding-banner/dismiss.json'
        expect(response.status).to eq(404)
      end
    end

    context 'plugin enabled' do
      before do
        SiteSetting.discourse_onboarding_banner_enabled = true
      end

      context 'without setting a topic_id' do
        it 'returns error when getting content' do
          get '/discourse-onboarding-banner/content.json'

          json = response.parsed_body
          expect(json['topic_id']).to eq(nil)
        end

        it 'returns error dismissing content' do
          put '/discourse-onboarding-banner/dismiss.json'
          expect(response.status).to eq(404)
        end
      end

      context 'after setting a topic_id' do
        fab!(:lounge) { Fabricate(:category, name: I18n.t("vip_category_name")) }
        fab!(:topic) { Fabricate(:topic, category: lounge) }
        fab!(:post) { Fabricate(:post, topic: topic, raw: 'My onboarding content') }

        before do
          SiteSetting.discourse_onboarding_banner_topic_id = topic.id
        end

        it 'returns content' do
          get '/discourse-onboarding-banner/content.json'
          expect(response.status).to eq(200)

          json = response.parsed_body
          expect(json['topic_id']).to eq(topic.id)
          expect(json['cooked']).to include('My onboarding content')
        end

        it 'stores topic dismissal' do
          put '/discourse-onboarding-banner/dismiss.json', params: { topic_id: topic.id }
          expect(response.status).to eq(200)

          expect(user.custom_fields).to eq({ 'onboarding_banner_dismissed_topic_id' => topic.id.to_s })

          get '/discourse-onboarding-banner/content.json'

          json = response.parsed_body
          expect(json['topic_id']).to eq(nil)
        end
      end

      context 'setting an invalid topic_id' do
        it 'returns an empty topic_id if topic_id is nil' do
          SiteSetting.discourse_onboarding_banner_topic_id = nil

          get '/discourse-onboarding-banner/content.json'

          json = response.parsed_body
          expect(json['topic_id']).to eq(nil)
        end

        it 'returns an empty topic_id if topic_id is invalid' do
          SiteSetting.discourse_onboarding_banner_topic_id = 99_999_999

          get '/discourse-onboarding-banner/content.json'

          json = response.parsed_body
          expect(json['topic_id']).to eq(nil)
        end
      end
    end
  end
end
