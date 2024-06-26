# Contributing to build-avr-gcc

The following is a set of guidelines for contributing to build-avr-gcc.
Note that these are guidelines, not rules.
Use your best judgment.

# Contents

- [I have a question](#i-have-a-question)
- [How can I contribute](#how-can-i-contribute)
    - [Report a bug](#report-a-bug)
    - [Implement a bug fix](#implement-a-bug-fix)
    - [Request an enhancement to an existing feature](#request-an-enhancement-to-an-existing-feature)
    - [Design an enhancement to an existing feature](#design-an-enhancement-to-an-existing-feature)
    - [Implement an enhancement to an existing feature](#implement-an-enhancement-to-an-existing-feature)
    - [Request a new feature](#request-a-new-feature)
    - [Design a new feature](#design-a-new-feature)
    - [Implement a new feature](#implement-a-new-feature)
    - [Perform a refactoring](#perform-a-refactoring)
- [Style-guide](#style-guide)

# I have a question

If you have a question, please review the relevant project documentation, and
search/browse existing issues and discussions.
If you have not found an answer to your question after reviewing the relevant project
documentation and searching/browsing existing issues and discussions, please open a
discussion to ask your question.

# How can I contribute

## Report a bug

To report a bug, please use the `bug` issue template to open an issue that details the bug
that was encountered.
Please provide as much detail as possible, covering things such as:
- The build-avr-gcc version (Git commit SHA)
- Description of expected behavior, and observed behavior
- Relevant code and steps required to reproduce the bug

If the bug report can be verified, the changes required to fix the bug will be captured in
the issue in preparation for implementing the bug fix.

## Implement a bug fix

Issues for implementing bug fixes can be found by looking for issues with the `type-bug`
type label and `status-awaiting_development` status label.
To implement a bug fix, please open a draft pull request that references the associated
issue and implement the bug fix.
Please mark the pull request as "Ready for review" and request a review when the pull
request is ready for a review.
If changes are requested, please discuss and/or address the review findings before
requesting a new review.

## Request an enhancement to an existing feature

To request an enhancement to an existing feature, please use the `enhancement-request`
issue template to open an issue that details the desired enhancement.
Please provide as much detail as possible, covering things such as:
- The use case(s) for the enhancement
- Description of current behavior, and how it will change

If the request for the enhancement to the existing feature is accepted, issue(s) for
designing or implementing the enhancement will be created as appropriate.

## Design an enhancement to an existing feature

To design an enhancement to an existing feature, please use the `enhancement-design` issue
template to open an issue that details the design.
Please provide as much detail as possible, covering things such as:
- The use case(s) for the enhancement
- Description of current behavior, and how it will change
- Detailed designs for all types, constants, and functions required to implement the
  enhancement

If the design for the enhancement to the existing feature is accepted, issue(s) for
implementing the enhancement will be created.

## Implement an enhancement to an existing feature

Issues for implementing enhancements to existing features can be found by looking for
issues with the `type-enhancement` type label and `status-awaiting_development` status
label.
To implement an enhancement to an existing feature, please open a draft pull request that
references the associated issue and implement the enhancement.
Please mark the pull request as "Ready for review" and request a review when the pull
request is ready for a review.
If changes are requested, please discuss and/or address the review findings before
requesting a new review.

## Request a new feature

To request a new feature, please use the `feature-request` issue template to open an issue
that details the desired new feature.
Please provide as much detail as possible, covering things such as:
- The use case(s) for the new feature
- Description of the desired behavior for the new feature

If the request for the new feature is accepted, issue(s) for designing or implementing the
feature will be created as appropriate.

## Design a new feature

To design a new feature, please use the `feature-design` issue template to open an issue
that details the design.
Please provide as much detail as possible, covering things such as:
- The use case(s) for the new feature
- Description of the desired behavior for the new feature
- Detailed designs for all types, constants, and functions required to implement the
  feature

If the design for the new feature is accepted, issue(s) for implementing the feature will
be created.

## Implement a new feature

Issues for implementing a new feature can be found by looking for issues with the
`type-feature` type label and `status-awaiting_development` status label.
To implement a new feature, please open a draft pull request that references the
associated issue and implement the feature.
Please mark the pull request as "Ready for review" and request a review when the pull
request is ready for a review.
If changes are requested, please discuss and/or address the review findings before
requesting a new review.

## Perform a refactoring

Issues for performing a refactoring can be found by looking for issues with the
`type-refactoring` type label and `status-awaiting_development` status label.
To perform a refactoring, please open a draft pull request that references the associated
issue and perform the refactoring.
Please mark the pull request as "Ready for review" and request a review when the pull
request is ready for a review.
If changes are requested, please discuss and/or address the review findings before
requesting a new review.

# Style guide

Formatting for all source code and content is neither automated nor documented (with the
exception of a column limit) at this time.
Please use a column limit of 90 for source code and content.
Please imitate the formatting of existing source code and content when adding or modifying
source code or content.

All non-formatting style issues are neither enforced via automation nor documented at this
time.
Please imitate existing source code and content when adding or modifying source code or
content.
