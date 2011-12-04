Feature: RightHTTPConnection can connect to a secure web server
  In order to access HTTP resources in a secure robust fashion
  RightHTTPConnection users should be able to connect to a web server that uses HTTPS
  And download data

  Scenario: normal operation
    Given an HTTPS URL
    And a really dumb SSL enabled web server
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL

  Scenario: normal operation with ssl handshake
    Given a test client certificate file
    Given a test client key file
    Given a CA certification file containing that server
    And enabled server cert verification
    Given an HTTPS URL
    And a really dumb SSL handshake enabled web server
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL
    And there should not be a warning about certificate verification failing

  Scenario: ssl handshake without server cert verification
    Given a test client certificate file
    Given a test client key file
    Given an HTTPS URL
    And a really dumb SSL handshake enabled web server
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL
    And there should be a warning about certificate verification failing

  Scenario: failed ssl handshake
    Given a not verified test client certificate file
    Given a not verified test client key file
    Given a CA certification file not containing that server
    And enabled server cert verification
    Given an HTTPS URL
    And a really dumb SSL handshake enabled web server
    When I request that URL using RightHTTPConnection
    Then I should get an exception
    And there should be a warning about certificate verification failing

  Scenario: normal operation with a CA certification file
    Given a CA certification file containing that server
    Given an HTTPS URL
    And a really dumb SSL enabled web server
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL
    And there should not be a warning about certificate verification failing

  Scenario: man in the middle
    Given a CA certification file not containing that server
    Given an HTTPS URL
    And a really dumb SSL enabled web server
    When I request that URL using RightHTTPConnection
    Then I should get the contents of the URL
    And there should be a warning about certificate verification failing

  Scenario: strict man in the middle
    Given a CA certification file not containing that server
    And enabled server cert verification
    Given an HTTPS URL
    And a really dumb SSL enabled web server
    And the strict failure option turned on
    When I request that URL using RightHTTPConnection
    Then I should get an exception
