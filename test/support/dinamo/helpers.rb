module Dinamo
  module Test
    module Helpers
      def create_dinamo(klass: DinamoTest, **attributes)
        klass.create(**make_primary_keys(klass: klass), **attributes)
      end

      def create_dinamo!(klass: DinamoTest, **attributes)
        klass.create!(**make_primary_keys(klass: klass), **attributes)
      end

      def build_dinamo(klass: DinamoTest, **attributes)
        klass.new(**make_primary_keys(klass: klass), **attributes)
      end

      def make_primary_keys(klass: nil)
        { id: uniq_id(klass), type: "test" }
      end

      private

      def uniq_id(klass)
        klass ||= DinamoTest
        begin
          uid = rand(100000)
        end while klass.get(type: "test", id: uid)
        ids << uid
        uid
      end

      def ids
        @ids ||= []
      end
    end
  end
end
