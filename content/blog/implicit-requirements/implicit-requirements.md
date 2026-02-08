---
title: Handle Implicit Requirements
description: Implicit requirements which usually overlooked by product
date: 2025-12-28
tags:
  - product management
layout: layouts/post.njk
---

## Introduction
How to spot the implicit requirements that product team might have overlooked ?

Implicit requirements are the ones that tend to be overlooked during design phase. Product expect it to work naturally while it's actually not. It hurts the development process by unexpected bugs and rework and eventually delays the release.

## Benefits of handling it early
- Identifying implicit requirements helps to properly manage the deadline and improve the quality of the product.
- Addressing implicit requirements early can help prevent costly rework later. 

Here's some examples I encountered:

## Side effect on other entities
- Example: Users can delete their account.
    - What happens to their **Orders** placed?
    - What happens to their **Comments** on shared documents?

## Uniqueness Constraints
- Which fields should be unique, and at what scope?
- Should we auto-generate human-friendly unique ID for users ? If so, how to handle the uniqueness constraint ?
- What about soft-deleted records?
    - note: **partial index on only active records**

## Permission Gaps
User has permission for Entity A but needs to display data from Entity B they can't access.

- Example: Sales Representative can view and create **orders** but **cannot access invoice details**. However, in order page we need to display the **invoice** details.
    - Question to clarify: Should we define fields in **invoice** that are public ?
- Example: In UI user is displayed as a name with a link. However for users who cannot access **User** detail page, it will go to 404 page.

## Searchable fields
- Searching for related field would affect data modeling e.g..
- Example: Search order by customer name → it might need to join/denormalize and create index on customer name.
    - Ask product about sorting, filtering, and full-text search needs.
