require 'faraday'
require 'faraday_middleware'
require_relative '../helper/pgyer_cl_helper'

module Fastlane
  module Actions
    class PgyerClAction < Action
      def self.run(params)
        UI.message("pgyer_cl开始工作!")

        api_host = "https://www.pgyer.com/apiv2/app/upload"
        api_key = params[:api_key]
        user_key = params[:user_key]
        fs_access_token = params[:fs_access_token]
        environment = params[:environment]

        if environment.nil?
          environment = "dev"
        end

        appEnvironment = "测试环境"
        if environment == "pub"
          appEnvironment = "正式环境"
        end

        # start upload
        conn_options = {
            request: {
                timeout: 1000,
                open_timeout: 300
            }
        }

        info = nil

        if api_key != "test"
          build_file = [
              params[:ipa],
              params[:apk]
          ].detect { |e| !e.to_s.empty? }

          if build_file.nil?
            UI.user_error!("您需要配置一个上传的文件")
            return
          end

          UI.message "配置上传文件: #{build_file}"

          password = params[:password]
          if password.nil?
            password = ""
          end

          update_description = params[:update_description]
          if update_description.nil?
            update_description = appEnvironment
          end

          install_type = params[:install_type]
          if install_type.nil?
            install_type = "1"
          end

          channel_shortcut = params[:channel_shortcut]
          if channel_shortcut.nil?
            channel_shortcut = ""
          end

          pgyer_client = Faraday.new(nil, conn_options) do |c|
            c.request :multipart
            c.request :url_encoded
            c.response :json, content_type: /\bjson$/
            c.adapter :net_http
          end

          params = {
              '_api_key' => api_key,
              'userKey' => user_key,
              'buildPassword' => password,
              'buildUpdateDescription' => update_description,
              'buildInstallType' => install_type,
              'buildInstallDate' => "2",
              'buildChannelShortcut' => channel_shortcut,
              'file' => Faraday::UploadIO.new(build_file, 'application/octet-stream')
          }

          UI.message "开始上传文件 #{build_file} 到蒲公英..."

          response = pgyer_client.post api_host, params
          info = response.body

          if info['code'] != 0
            UI.user_error!("蒲公英组件错误信息: #{info['message']}")
            return
          else
            UI.success "蒲公英上传成功. 详见: https://www.pgyer.com/#{info['data']['buildShortcutUrl']}"
          end
        end

        appType = "Android";
        appName = "测试应用"
        appVersion = "1.0.0"
        appBuildVersion = 1
        appUrl = "https://www.pgyer.com/#{channel_shortcut}"

        if info != nil
          # 应用类型
          if info['data']['buildType'] == 1 || info['data']['buildType'] == "1"
            appType = "iOS"
          end
          # 应用名称
          appName = info['data']['buildName']
          # 应用版本信息
          appVersion = info['data']['buildVersion']
          # 应用蒲公英版本
          appBuildVersion = info['data']['buildBuildVersion']
          # 地址
          if channel_shortcut.nil?
            appUrl = "https://www.pgyer.com/#{info['data']['buildShortcutUrl']}"
          end
        else
        end

        unless fs_access_token.nil?
          UI.message("配置飞书参数")

          config = {
              "wide_screen_mode": false
          }

          header = {
              "title": {
                  "tag": "plain_text",
                  "content": "APP发布通知"
              },
              "template": "green"
          }

          content = {
              "tag": "div",
              "fields": [
                  {
                      "is_short": true,
                      "text": {
                          "tag": "lark_md",
                          "content": "**APP名称：**\n#{appName}"
                      }
                  },
                  {
                      "is_short": true,
                      "text": {
                          "tag": "lark_md",
                          "content": "**环境：**\n#{appEnvironment}"
                      }
                  },
                  {
                      "is_short": false,
                      "text": {
                          "tag": "lark_md",
                          "content": ""
                      }
                  },
                  {
                      "is_short": true,
                      "text": {
                          "tag": "lark_md",
                          "content": "**蒲公英版本：**\n#{appVersion}+#{appBuildVersion}"
                      }
                  },
                  {
                      "is_short": true,
                      "text": {
                          "tag": "lark_md",
                          "content": "**下载地址：**\n<a>#{appUrl}</a>"
                      }
                  },
                  {
                      "is_short": false,
                      "text": {
                          "tag": "lark_md",
                          "content": ""
                      }
                  },
                  {
                      "is_short": false,
                      "text": {
                          "tag": "lark_md",
                          "content": "**更新内容：**\n#{update_description}"
                      }
                  }
              ]
          }

          action = {
              "tag": "action",
              "actions": [
                  {
                      "tag": "button",
                      "text": {
                          "tag": "plain_text",
                          "content": "查看详情"
                      },
                      "url": "#{appUrl}",
                      "type": "primary"
                  }
              ]
          }

          message_post = "https://open.feishu.cn/open-apis/bot/v2/hook/#{fs_access_token}";

          params = {
              "msg_type": "interactive",
              "card": {
                  "config": config,
                  "header": header,
                  "elements": [
                      content,
                      action,
                  ]
              }
          }

          UI.message("发送飞书消息")

          message_client = Faraday.new(nil, conn_options) do |c|
            c.request :json
            c.request :url_encoded
            c.response :json, content_type: /\bjson$/
            c.adapter :net_http
          end

          response = message_client.post message_post, params
          message_info = response.body

          if message_info['StatusCode'] != 0
            UI.error("飞书消息发送失败: #{message_info["StatusMessage"]}")
          else
            UI.success('发送飞书消息成功');
          end
        end

        UI.message('pgyer_cl工作结束!')
      end

      def self.description
        "pgyer_cl"
      end

      def self.authors
        ["陈磊"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "pgyer_cl"
      end

      def self.available_options
        [
            FastlaneCore::ConfigItem.new(key: :api_key,
                                         env_name: "PGYER_API_KEY",
                                         description: "api_key in your pgyer account",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :user_key,
                                         env_name: "PGYER_USER_KEY",
                                         description: "user_key in your pgyer account",
                                         optional: false,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :apk,
                                         env_name: "PGYER_APK",
                                         description: "Path to your APK file",
                                         default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH],
                                         optional: true,
                                         verify_block: proc do |value|
                                           UI.user_error!("Couldn't find apk file at path '#{value}'") unless File.exist?(value)
                                         end,
                                         conflicting_options: [:ipa],
                                         conflict_block: proc do |value|
                                           UI.user_error!("You can't use 'apk' and '#{value.key}' options in one run")
                                         end),
            FastlaneCore::ConfigItem.new(key: :ipa,
                                         env_name: "PGYER_IPA",
                                         description: "Path to your IPA file. Optional if you use the _gym_ or _xcodebuild_ action. For Mac zip the .app. For Android provide path to .apk file",
                                         default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH],
                                         optional: true,
                                         verify_block: proc do |value|
                                           UI.user_error!("Couldn't find ipa file at path '#{value}'") unless File.exist?(value)
                                         end,
                                         conflicting_options: [:apk],
                                         conflict_block: proc do |value|
                                           UI.user_error!("You can't use 'ipa' and '#{value.key}' options in one run")
                                         end),
            FastlaneCore::ConfigItem.new(key: :password,
                                         env_name: "PGYER_PASSWORD",
                                         description: "set password to protect app",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :update_description,
                                         env_name: "PGYER_UPDATE_DESCRIPTION",
                                         description: "set update description for app",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :install_type,
                                         env_name: "PGYER_INSTALL_TYPE",
                                         description: "set install type for app (1=public, 2=password, 3=invite). Please set as a string",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :channel_shortcut,
                                         env_name: "PGYER_CHANNEL",
                                         description: "Use channel short link. Please set as a string",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :fs_access_token,
                                         env_name: "FS_ACCESS_TOKEN",
                                         description: "Set up webhook and push update messages. Please set as a string",
                                         optional: true,
                                         type: String),
            FastlaneCore::ConfigItem.new(key: :environment,
                                         env_name: "ENVIRONMENT",
                                         description: "set environment (dev, pub). Please set as a string",
                                         optional: true,
                                         type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
        #
        [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
