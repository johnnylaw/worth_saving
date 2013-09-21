# worth_saving gem

[![Build Status](https://travis-ci.org/johnnylaw/worth_saving.png)](http://travis-ci.org/johnnylaw/worth_saving)
[![Code Climate](https://codeclimate.com/github/johnnylaw/worth_saving.png)](https://codeclimate.com/github/johnnylaw/worth_saving)
[![Coverage Status](https://coveralls.io/repos/johnnylaw/worth_saving/badge.png)](https://coveralls.io/r/johnnylaw/worth_saving)
[![Gem Version](https://badge.fury.io/rb/worth_saving.png)](http://badge.fury.io/rb/worth_saving)

### What is worth_saving?

The worth_saving gem is a Rails engine intended for those creating web applications whose forms are long, where editing can sometimes go on for a long period without saving.  When recovery of these unsaved edits is important, the worth_saving gem's magic makes saving and recovering draft copies a cinch.

### How to start?

Install worth_saving as a gem:

    gem install worth_saving

or include worth_saving in your Gemfile with `gem 'worth_saving'` and running `bundle install`.

One database table called `worth_saving_drafts` is required, which can be created with

    rake worth_saving:install:migrations

and

    rake db:migrate

To completely set up your application to work you will need to include the following in one of your javascript manifests that is included wherever you will use worth_saving:

    //= require worth_saving

You may also include the following in a stylesheet manifest, although you may find that you want to define your own CSS:

    /*= require worth_saving

By mounting the engine in your routes.rb file, you will provide the necessary routing for drafts to save automatically while editing objects whose classes use the worth_saving functionality:

    mount WorthSaving::Engine => '/worth_saving'

In any model whose edits you want to draft, place the following:

    class Example < ActiveRecord::Base
      is_worth_saving
    end

There are two options:

    is_worth_saving scope: :user, except: :title

#### The :scope option

When working on a new record, the draft copy is saved without the benefit of an ID on the main record being drafted, but it is imperative for retrieving the draft later that some uniquely identifying information be saved in the draft.  In the example above, perhaps the Page class is_worth_saving.  If a page belongs_to :user, then a natural choice for scope would be user.  In this way you ensure that two different users with unsaved changes to new Page records cannot accidentally retrieve and see one another's drafts.

#### The :except option

Certain fields may contain sensitive information that should not be drafted.  Additionally any filter_parameters from your Rails app config will always be redacted from the WorthSaving::Draft records to maintain the privacy you would expect for your users.

#### Creating a form that autosaves drafts

To invoke the form that will automatically incorporate all the magic, use the following wherever you would use form_for:

    worth_saving_form_for(@page, save_interval: 15, recovery_message: I18n.t("worth_saving.recovery_message")) do |f|
      = f.label :title
      br
      = f.text_field :title

      ...


The :save_interval option is the number of seconds that will pass after the first unsaved change before firing a draft copy off to the engine.  It is not necessary to put this option here, and it defaults to whatever you set it in initialization or 60 seconds if you do nothing:

    WorthSaving.configure do |config|
      config.default_save_interval = <number of seconds to wait after changes occur before saving draft>
    end

The :recovery_message is a message that appears when a user visits a page where the record being edited has a draft copy.  It too has a default already built in, which can be overridden in the configure block or fed as an option to #worth_saving_form_for as above.

#### Security

Not just anyone should be able to save a draft copy of a record; only someone authorized to edit that record should.  Two methods can be implemented in your ApplicationController class to prevent people from saving drafts to records they do not have the authority to edit (or scopes they do have the authority to add records to).  The WorthSaving::DraftsController will defer to these methods when processing draft posts/patches/puts if they are defined in ApplicationController.  If you do not implement them here, it's assumed that anyone can create a draft for any record.  It is recommended you implement these if the records themselves require authorization.

Example (How you might implement these methods if using CanCan; #authorized_to_draft_with_scope? will be called only if the record is not persisted):

    class ApplicationController < ActionController::Base
      def authorized_to_draft_record?(record)
        can? :manage, record
      end

      def authorized_to_draft_with_scope?(scope)
        can? :add_records, scope
      end
    end

#### Upcoming changes
* support for simple_form
* support for TinyMCE and CKEditor (currently the values in the editor window can be overlooked, as the JS simply grabs the value of the textarea or input)
* support for additional namespaced DraftsControllers that inherit from controllers in your application (e.g. class WorthSaving::Admin::DraftsController < AdminController accessed automatically when invoking worth_saving_form_for [:admin, @record] ...)

