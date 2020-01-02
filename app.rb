require 'sinatra'
require 'sinatra/config_file'

require 'json'
require 'octokit'

config_file 'config.yml'

post '/payload' do
  client = Octokit::Client.new(:access_token => settings.github_auth_token)

  # =================================
  # 
  # These are the options noted in the API docs that are required for the PUT request 
  # for branch protection.
  #
  # If we need to change these settings frequently, move to a config file.
  # 
  # =================================

  protection_options = {
    :required_status_checks => nil,
    :enforce_admins => nil,
    :required_pull_request_reviews => nil,
    :restrictions => nil,
    :required_linear_history => false,
    :allow_force_pushes => false,
    :allow_deletions => false,
  }

  if request.env["HTTP_X_GITHUB_EVENT"] == "repository"
  # Only do something when receiving a payload for a repository

    push = JSON.parse(request.body.read)
    org = push.dig("organization", "login")
    action = push.dig("action")
    repo_id = push.dig("repository", "id")

    if org == settings.github_org && action == "created"
    # if we have created a new repo in our Org

      # @client.edit_branch_protection(repo_id, 'master', *options)

      client.create_issue(
          repo_id,
          '[bot] Branch Protections Added to master branch',
          "@#{settings.github_user},
          \n\nBranch protections were added to this repository with options:
          \n\n`#{protection_options.inspect}`")
    end
  end
end
