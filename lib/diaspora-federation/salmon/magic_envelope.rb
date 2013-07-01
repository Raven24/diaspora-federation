
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
    attr_reader :payload

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

    # encrypts the payload with a new AES cipher and returns the cipher params
    # @return [Hash] { key: '...', iv: '...' }
    def encrypt!
      encryption_data = Salmon.aes_encrypt(@payload)
      @payload = encryption_data[:ciphertext]

      { key: encryption_data[:key], iv: encryption_data[:iv] }
    end

    # extracts the entity encoded in the magic envelope data
    # does some sanity checking to avoid bad surprises
    # @param [Ox::Element]
    # @param [OpenSSL::PKey::RSA] public_key to verify the signature
    # @param [Hash] { iv: '...', key: '...' } for decrypting previously encrypted data
    # @return [Entity]
    def self.unenvelop(magic_env, rsa_pubkey, cipher_params=nil)
      raise ArgumentError unless rsa_pubkey.instance_of?(OpenSSL::PKey::RSA) &&
                                 magic_env.instance_of?(Ox::Element)
      raise InvalidEnvelope unless envelope_valid?(magic_env)
      raise InvalidSignature unless signature_valid?(magic_env, rsa_pubkey)

      enc = magic_env.locate('me:encoding').first.text
      alg = magic_env.locate('me:alg').first.text

      raise InvalidEncoding unless enc == ENCODING
      raise InvalidAlgorithm unless alg == ALGORITHM

      data = Base64.urlsafe_decode64(magic_env.locate('me:data').first.text)
      unless cipher_params.nil?
        data = Salmon.aes_decrypt(data, cipher_params[:key], cipher_params[:iv])
      end
      XmlPayload.unpack(Ox.parse(data))
    end

    private

    # create the signature for all fields according to specification
    def signature
      subject = self.class.sig_subject([@payload,
                                        DATA_TYPE,
                                        ENCODING,
                                        ALGORITHM])
      @rsa_pkey.sign(DIGEST, subject)
    end

    # @param [Ox::Element]
    def self.envelope_valid?(env)
      (env.instance_of?(Ox::Element) &&
        env.name == 'me:env' &&
        !env.locate('me:data').empty? &&
        !env.locate('me:encoding').empty? &&
        !env.locate('me:alg').empty? &&
        !env.locate('me:sig').empty?)
    end

    # @param [Ox::Element]
    # @param [OpenSSL::PKey::RSA] public_key
    def self.signature_valid?(env, pkey)
      subject = sig_subject([Base64.urlsafe_decode64(env.locate('me:data').first.text),
                             env.locate('me:data').first['type'],
                             env.locate('me:encoding').first.text,
                             env.locate('me:alg').first.text])

      sig = Base64.urlsafe_decode64(env.locate('me:sig').first.text)
      pkey.verify(DIGEST, sig, subject)
    end

    # constructs the signature subject.
    # the given array should consist of the data, data_type (mimetype), encoding
    # and the algorithm
    # @param [Array<String>]
    def self.sig_subject(data_arr)
      data_arr.map { |i| Base64.urlsafe_encode64(i) }.join('.')
    end

    # specific errors

    class InvalidEnvelope < RuntimeError
    end

    class InvalidSignature < RuntimeError
    end

    class InvalidAlgorithm < RuntimeError
    end

    class InvalidEncoding < RuntimeError
    end
  end
end; end
