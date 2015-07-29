require 'redis-objects'

module WebsocketRails

  class << self

    def channel_manager
      @channel_manager ||= ChannelManager.new
    end

    def [](channel)
      channel_manager[channel]
    end

    def channel_tokens
      channel_manager.channel_tokens
    end

    def filtered_channels
      channel_manager.filtered_channels
    end

  end

  class ChannelManager

    attr_reader :channels, :filtered_channels
    delegate :sync, to: Synchronization

    def initialize
      @channels = {}.with_indifferent_access
      @filtered_channels = {}.with_indifferent_access
    end

    def register_channel(name, token)
      channel_tokens[name] = token
    end

    def channel_tokens
      @channel_tokens ||= begin
        if WebsocketRails.synchronize?
          sync.channel_tokens
        else
          @channel_tokens ||= {}
        end
      end
    end

    def [](channel)
      @channels[channel] ||= Channel.new channel
    end

    def unsubscribe(connection)
      @channels.each do |channel_name, channel|
        channel.unsubscribe(connection)
      end
    end

  end
end
