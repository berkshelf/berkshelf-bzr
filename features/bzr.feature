Feature: Installing from a bazaar location

  Scenario: installing a demand from a Bzr location
    Given a remote bazaar cookbook named "fake"
    And I write a Berksfile with:
      """
      source 'https://api.berkshelf.com'
      extension 'bzr'

      cookbook 'fake', bzr: "#{Dir.pwd}/bzr-cookbooks/fake"
      """
    When I successfully run `berks install`
    Then the cookbook store should have the bzr cookbooks:
      | fake | 1.0.0 | 14ff121c2fd9f70f1db9fe0824a5880b6f91da20 |
    And the output should contain:
      """
      Using fake (1.0.0)
      """

  Scenario: installing a demand from a Bzr location that has already been installed
    Given a remote bazaar cookbook named "fake"
    Given I write a Berksfile with:
      """
      source 'https://api.berkshelf.com'
      extension 'bzr'

      cookbook 'fake', bzr: "#{Dir.pwd}/bzr-cookbooks/fake"
      """
    And the cookbook store has the bzr cookbooks:
      | fake | 1.0.0 | 14ff121c2fd9f70f1db9fe0824a5880b6f91da20 |
    When I successfully run `berks install`
    Then the output should contain:
      """
      Using fake (1.0.0)
      """

  Scenario: installing a Berksfile that contains a Bzr location with a ref
    Given a remote bazaar cookbook named "fake" with a ref named "revno:1"
    Given I write a Berksfile with:
      """
      source 'https://api.berkshelf.com'
      extension 'bzr'

      cookbook 'fake', bzr: "#{Dir.pwd}/bzr-cookbooks/fake", ref: 'revno:1'
      """
    When I successfully run `berks install`
    Then the cookbook store should have the bzr cookbooks:
      | fake | 1.0.0 | 14ff121c2fd9f70f1db9fe0824a5880b6f91da20 |
    And the output should contain:
      """
      Using fake (1.0.0)
      """

  Scenario: with a bzr error during download
    Given a remote bazaar cookbook named "fake" with a ref named "revno:1"
    Given I write a Berksfile with:
      """
      source 'https://api.berkshelf.com'
      extension 'bzr'

      cookbook 'fake', bzr: "#{Dir.pwd}/bzr-cookbooks/fake", ref: 'revno:1'
      cookbook "doesntexist", bzr: "bzr+ssh://github.com/asdjhfkljashflkjashfakljsf"
      """
    When I run `berks install`
    Then the output should contain:
      """
      Bzr error
      """
      And the exit status should be "BzrLocation::BzrError"
