module Appsignal
  module Probes
    class GvlProbe
      include Helpers

      # @api private
      def self.dependencies_present?
        defined?(::GVLTools) && gvltools_0_2_or_newer? && ruby_3_2_or_newer?
      end

      # @api private
      def self.gvltools_0_2_or_newer?
        Gem::Version.new(::GVLTools::VERSION) >= Gem::Version.new("0.2.0")
      end

      # @api private
      def self.ruby_3_2_or_newer?
        Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.2.0")
      end

      def initialize(appsignal: Appsignal, gvl_tools: ::GVLTools)
        Appsignal.logger.debug("Initializing GVL probe")
        @appsignal = appsignal
        @gvl_tools = gvl_tools
      end

      def call
        probe_global_timer if @gvl_tools::GlobalTimer.enabled?
        probe_waiting_threads if @gvl_tools::WaitingThreads.enabled?
      end

      private

      def probe_global_timer
        monotonic_time_ns = @gvl_tools::GlobalTimer.monotonic_time
        gauge_delta :gvl_global_timer, monotonic_time_ns do |time_delta_ns|
          time_delta_ms = time_delta_ns / 1_000_000
          set_gauge("gvl_global_timer", time_delta_ms)
        end
      end

      def probe_waiting_threads
        set_gauge("gvl_waiting_threads", @gvl_tools::WaitingThreads.count)
      end
    end
  end
end
