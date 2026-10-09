@bdd
Feature: The site's search box lists its results in the order of the course
  As a student who searches the site with its «Búsqueda» box
  I want the pages found listed in the order of the course
  So that I read them as the course presents them, from the first chapter on

  Scenario: Search results come in chapter order
    Given a student reading the page "capitulo-07-listas/"
    When the student searches the site for "lista"
    Then the site search lists its results in the order of the course
