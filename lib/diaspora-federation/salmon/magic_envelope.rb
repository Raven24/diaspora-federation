
# a magic envelope for Diaspora* appears like so:
#
#  <me:env>
#    <me:data type='application/xml'>{data}</me:data>
#    <me:encoding>base64url</me:encoding>
#    <me:alg>RSA-SHA256</me:alg>
#    <me:sig>{signature}</me:sig>
#  </me:env>
#
# for details, see: http://www.salmon-protocol.org/
# and: http://salmon-protocol.googlecode.com/svn/trunk/draft-panzer-magicsig-01.html

module DiasporaFederation; module Salmon
  class MagicEnvelope
    module ClassMethods
      # @param [Ox::Element]
      def envelope_valid?(env)
        (env.instance_of?(Ox::Element) &&
         env.name == 'me:env' &&
         !env.locate('me:data').empty? &&
         !env.locate('me:encoding').empty? &&
         !env.locate('me:alg').empty? &&
         !env.locate('me:sig').empty?)
      end

      # @param [Ox::Element]
      # @param [OpenSSL::PKey::RSA] public_key
      def signature_valid?(env, pkey)
        subject = [Base64.urlsafe_decode64(env.locate('me:data').first.text),
                   env.locate('me:data').first['type'],
                   env.locate('me:encoding').first.text,
                   env.locate('me:alg').first.text]
                  .map { |i| Base64.urlsafe_encode64(i) }.join('.')
        sig = Base64.urlsafe_decode64(env.locate('me:sig').first.text)
        pkey.verify(DIGEST, sig, subject)
      end
    end

    self.extend MagicEnvelope::ClassMethods

    # encoding used for the payload data
    ENCODING = 'base64url'

    # algorithm used for signing the payload data
    ALGORITHM = 'RSA-SHA256'

    # mime type describing the payload data
    DATA_TYPE = 'application/xml'

    # digest instance used for signing
    DIGEST = OpenSSL::Digest::SHA256.new

    # @param [OpenSSL::PKey::RSA]
    # @param [Entity]
    def initialize(rsa_pkey, payload)
      raise ArgumentError unless rsa_pkey.instance_of?(OpenSSL::PKey::RSA) &&
                                 payload.is_a?(Entity)

      @rsa_pkey = rsa_pkey
      @payload = Ox.dump(XmlPayload.pack(payload)).strip
    end

    # builds the xml structure for the magic envelope
    # @return [Ox::Element]
    def envelop
      env = Ox::Element.new('me:env')

      data = Ox::Element.new('me:data')
      data['type'] = DATA_TYPE
      data << Base64.urlsafe_encode64(@payload)
      env << data

      enc = Ox::Element.new('me:encoding')
      enc << ENCODING
      env << enc

      alg = Ox::Element.new('me:alg')
      alg << ALGORITHM
      env << alg

      sig = Ox::Element.new('me:sig')
      sig << Base64.urlsafe_encode64(signature)
      env << sig

      env
    end

    # @param [Ox::Element]
    # @param [OpenSSL::PKey::RSA] public_key to verify the signature
    # @return [Entity]
    def self.unenvelop(magic_env, rsa_pubkey)
      raise ArgumentError unless rsa_pubkey.instance_of?(OpenSSL::PKey::RSA) &&
                                 magic_env.instance_of?(Ox::Element)
      raise InvalidEnvelope unless envelope_valid?(magic_env)
      raise InvalidSignature unless signature_valid?(magic_env, rsa_pubkey)

      data = Base64.urlsafe_decode64(magic_env.locate('me:data').first.text)
      XmlPayload.unpack(Ox.parse(data))
    end

    private

    def signature
      subject = [@payload,
                 DATA_TYPE,
                 ENCODING,
                 ALGORITHM].map { |i| Base64.urlsafe_encode64(i) }.join('.')
      @rsa_pkey.sign(DIGEST, subject)
    end

    # specific errors

    class InvalidEnvelope < RuntimeError
    end

    class InvalidSignature < RuntimeError
    end
  end
end; end
