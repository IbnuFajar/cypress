require("../spec_helper")

cors = require("#{root}lib/util/cors")

describe "lib/util/cors", ->
  context ".parseUrlIntoDomainTldPort", ->
    beforeEach ->
      @isEq = (url, obj) ->
        expect(cors.parseUrlIntoDomainTldPort(url)).to.deep.eq(obj)

    it "parses https://www.google.com", ->
      @isEq("https://www.google.com", {
        port: "443"
        domain: "google"
        tld: "com"
      })

  context ".urlMatchesOriginPolicyProps", ->
    beforeEach ->
      @isFalse = (url, props) =>
        expect(cors.urlMatchesOriginPolicyProps(url, props)).to.be.false

      @isTrue = (url, props) =>
        expect(cors.urlMatchesOriginPolicyProps(url, props)).to.be.true

    describe "domain + subdomain", ->
      beforeEach ->
        @props = cors.parseUrlIntoDomainTldPort("https://staging.google.com")

      it "does not match", ->
        @isFalse("https://foo.bar:443", @props)
        @isFalse("http://foo.bar:80", @props)
        @isFalse("http://foo.bar", @props)
        @isFalse("http://staging.google.com", @props)
        @isFalse("http://staging.google.com:80", @props)
        @isFalse("https://staging.google2.com:443", @props)
        @isFalse("https://staging.google.net:443", @props)
        @isFalse("https://google.net:443", @props)
        @isFalse("http://google.com", @props)

      it "matches", ->
        @isTrue("https://staging.google.com:443", @props)
        @isTrue("https://google.com:443", @props)
        @isTrue("https://foo.google.com:443", @props)
        @isTrue("https://foo.bar.google.com:443", @props)

    describe "localhost", ->
      beforeEach ->
        @props = cors.parseUrlIntoDomainTldPort("http://localhost:4200")

      it "does not match", ->
        @isFalse("http://localhost:4201", @props)
        @isFalse("http://localhoss:4200", @props)

      it "matches", ->
        @isTrue("http://localhost:4200", @props)

    describe "local", ->
      beforeEach ->
        @props = cors.parseUrlIntoDomainTldPort("http://brian.dev.local")

      it "does not match", ->
        @isFalse("https://brian.dev.local:443", @props)
        @isFalse("https://brian.dev.local", @props)
        @isFalse("http://brian.dev2.local:81", @props)

      it "matches", ->
        @isTrue("http://jennifer.dev.local:80", @props)
        @isTrue("http://jennifer.dev.local", @props)

    describe "ip address", ->
      beforeEach ->
        @props = cors.parseUrlIntoDomainTldPort("http://192.168.5.10")

      it "does not match", ->
        @isFalse("http://192.168.5.10:443", @props)
        @isFalse("https://192.168.5.10", @props)
        @isFalse("http://193.168.5.10", @props)
        @isFalse("http://193.168.5.10:80", @props)

      it "matches", ->
        @isTrue("http://192.168.5.10", @props)
        @isTrue("http://192.168.5.10:80", @props)
