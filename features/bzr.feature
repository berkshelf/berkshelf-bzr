Feature: Installing from a bazaar location
  Scenario: In the default scenario
    * a remote bazaar cookbook named "fake"
    * I write to "Berksfile" with:
      """
      source 'https://api.berkshelf.com'
      extension 'bzr'

      cookbook 'fake', bzr: "file://localhost#{Dir.pwd}/bzr-cookbooks/fake"
      """
    * I successfully run `berks install`
    * the output should contain "Using fake (1.0.0)"

  Scenario: When a ref is given
    * a remote bazaar cookbook named "fake" with a ref named "revno:2"
    * I write to "Berksfile" with:
      """
      source 'https://api.berkshelf.com'
      extension 'bzr'

      cookbook 'fake', hg: "file://localhost#{Dir.pwd}/bzr-cookbooks/fake", ref: 'revno:2'
      """
    * I successfully run `berks install`
    * the output should contain "Using fake (2.3.4)"
