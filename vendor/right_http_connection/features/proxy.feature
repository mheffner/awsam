Feature: RightHTTPConnection can connect to a web server through a proxy
  In order to access HTTP resources through web proxies
  RightHTTPConnection users should be able to connect to a web server proxy
  And make connections from there

  Scenario: normal operation
    Given a URL
    And a proxy
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL
    And the proxy should have been used

  Scenario: normal operation with username and password
    Given a URL
    And a proxy with a username and password
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL
    And the proxy should have been used

  Scenario: bad username and password
    Given a URL
    And a proxy with the wrong username and password
    When I request that URL using RightHTTPConnection
    Then I should get told to authenticate correctly

  Scenario: proxy doesn't like CONNECT requests
    Given a URL
    And a proxy that refuses CONNECT requests
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL
    And the proxy should have been used

  Scenario: intermittent failure
    Given a URL that fails intermittently
    And a proxy
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL eventually

  Scenario: read timeout
    Given a URL that hangs intermittently
    And a proxy
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL eventually

  Scenario: open timeout
    Given a URL whose server is unreliable
    And a proxy
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL eventually

  Scenario: consistent failure
    Given a URL that fails all the time
    And a proxy
    When I request that URL using RightHTTPConnection
    Then I should get an exception

  Scenario: consistent read timeout
    Given a URL that hangs all the time
    And a proxy
    When I request that URL using RightHTTPConnection
    Then I should get an exception

  Scenario: consistent open timeout
    Given a URL whose server is listening but always down
    And a proxy
    When I request that URL using RightHTTPConnection
    Then I should get an exception
