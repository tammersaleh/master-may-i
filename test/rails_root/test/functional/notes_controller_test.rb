require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  setup :activate_authlogic
  
  as_a_logged_in_user do
    who_can_manage :notes do
      context "on GET to /notes/new" do
        setup { get :new }
        should_not_set_the_flash
        should_render_template :new
      end

      context "on POST to /notes" do
        setup { post :create, :note => {} }
        should_set_the_flash_to /created/i
      end

      context "given a note" do
        setup { @note = Factory(:note) }

        context "on GET to /notes/:id" do
          setup { get :show, :id => @note }
          should_not_set_the_flash
          should_render_template :show
        end

        context "on GET to /notes/:id/edit" do
          setup { get :edit, :id => @note }
          should_not_set_the_flash
          should_render_template :edit
        end

        context "on PUT to /notes/:id" do
          setup { put :update, :id => @note.to_param, :note => {} }
          should_set_the_flash_to /updated/i
        end

        context "on DELETE to /notes/:id" do
          setup { delete :destroy, :id => @note.to_param }
          should_set_the_flash_to /destroyed/i
        end
      end
    end

    who_cannot_manage :notes do
      context "on GET to /notes/new" do
        setup { get :new }
        should_be_denied_as_user
      end

      context "on POST to /notes" do
        setup { post :create, :note => {} }
        should_be_denied_as_user
      end

      context "given a note" do
        setup { @note = Factory(:note) }

        context "on GET to /notes/:id" do
          setup { get :show, :id => @note }
          should_be_denied_as_user
        end

        context "on GET to /notes/:id/edit" do
          setup { get :edit, :id => @note }
          should_be_denied_as_user
        end

        context "on PUT to /notes/:id" do
          setup { put :update, :id => @note.to_param, :note => {} }
          should_be_denied_as_user
        end

        context "on DELETE to /notes/:id" do
          setup { delete :destroy, :id => @note.to_param }
          should_be_denied_as_user
        end
      end
    end
  end

  as_a_visitor do
    who_cannot_manage :notes do
      context "on GET to /notes/new" do
        setup { get :new }
        should_be_denied_as_visitor
      end

      context "on POST to /notes" do
        setup { post :create, :note => {} }
        should_be_denied_as_visitor
      end

      context "given a note" do
        setup { @note = Factory(:note) }

        context "on GET to /notes/:id" do
          setup { get :show, :id => @note }
          should_be_denied_as_visitor
        end

        context "on GET to /notes/:id/edit" do
          setup { get :edit, :id => @note }
          should_be_denied_as_visitor
        end

        context "on PUT to /notes/:id" do
          setup { put :update, :id => @note.to_param, :note => {} }
          should_be_denied_as_visitor
        end

        context "on DELETE to /notes/:id" do
          setup { delete :destroy, :id => @note.to_param }
          should_be_denied_as_visitor
        end
      end
    end
  end
end
