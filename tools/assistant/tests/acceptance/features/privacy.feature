@bdd
Feature: The question stays in the student's browser
  As a student
  I want my questions to stay on my computer
  So that nobody else learns what I asked

  Scenario: Asking sends nothing but requests for the site's own files
    Given a student reading the page "capitulo-07-listas/"
    And the page has finished loading
    When the student opens the panel and asks "¿Qué hace findall/3? zqxjvw"
    Then no request went to another host after the panel opened
    And no request carried "zqxjvw"
    And every request was for a file of the site
