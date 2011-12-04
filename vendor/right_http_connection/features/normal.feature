Feature: RightHTTPConnection can connect to a web server
  In order to access HTTP resources in a robust fashion
  RightHTTPConnection users should be able to connect to a web server
  And download data

  Scenario: normal operation
    Given a URL
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL

  Scenario: normal operation with user agent
    Given a URL
    And the user agent "RightScale test"
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL
    And the logs should show a "RightScale test" user agent

  Scenario: read timeout
    Given a URL that hangs intermittently
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL eventually

  Scenario: open timeout
    Given a URL whose server is unreliable
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL eventually

  Scenario: consistent failure
    Given a URL that fails all the time
    When I request that URL using RightHTTPConnection
    Then I should get an exception

  Scenario: consistent read timeout
    Given a URL that hangs all the time
    When I request that URL using RightHTTPConnection
    Then I should get an exception

  Scenario: consistent open timeout
    Given a URL whose server is listening but always down
    When I request that URL using RightHTTPConnection
    Then I should get an exception
