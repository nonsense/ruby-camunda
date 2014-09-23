require 'rest_client'

module Ruby
  module Camunda
    class Client

      def initialize uri, base_path = "/engine-rest"
        @uri = uri
        @base_path = base_path
        @use_history_endpoints = false

        @conn = Faraday.new(:url => @uri) do |faraday|
          faraday.request  :url_encoded
          faraday.response :logger
          faraday.adapter  Faraday.default_adapter
        end
      end

      def useHistoryEndpoints
        @use_history_endpoints = true
      end


      ###############
      ### TASKS
      ###############

      def getTasks params
        query_string = generateQueryString params

        result = RestClient.get @uri + @base_path + endpointPrefix + '/task' + query_string, :content_type => :json, :accept => :json

        JSON.parse(result)
      end

      def getTask id
        if @use_history_endpoints
          params = Hash.new
          params[:taskId] = id
          query_string = generateQueryString params

          result = RestClient.get @uri + @base_path + endpointPrefix + '/task' + query_string, :content_type => :json, :accept => :json

          retVal = JSON.parse(result)
          retVal = retVal[0] if retVal != nil
        else
          result = RestClient.get @uri + @base_path + '/task/' + id, :content_type => :json, :accept => :json

          retVal = JSON.parse(result)
        end
      end

      def completeTask id, json_params = '{}'
        url = @base_path + '/task/' + id + '/complete'

        @conn.post do |req|
          req.url url
          req.headers['Content-Type'] = 'application/json'
          req.body = json_params
        end
      end

      ###############
      ### PROCESS INSTANCES
      ###############

      def getProcessInstances params
        query_string = generateQueryString params

        result = RestClient.get @uri + @base_path + endpointPrefix + '/process-instance' + query_string, :content_type => :json, :accept => :json

        JSON.parse(result)
      end

      def getProcessInstance id
        result = RestClient.get @uri + @base_path + endpointPrefix + '/process-instance/' + id, :content_type => :json, :accept => :json

        JSON.parse(result)
      end

      def getHistoryProcessInstance id
        if id != nil
          result = RestClient.get @uri + @base_path + '/history/process-instance/' + id, :content_type => :json, :accept => :json

          return JSON.parse(result)
        end

        return {}
      end

      def getProcessInstanceVariables id
        if @use_history_endpoints
          params = Hash.new
          params[:processInstanceId] = id

          query_string = generateQueryString params

          result = RestClient.get @uri + @base_path + endpointPrefix + '/variable-instance' + query_string, :content_type => :json, :accept => :json
        else
          result = RestClient.get @uri + @base_path + '/process-instance/' + id + '/variables', :content_type => :json, :accept => :json
        end

        JSON.parse(result)
      end

      def deleteProcessInstance processInstanceId
        result = RestClient.delete @uri + @base_path + '/process-instance/' + processInstanceId, :content_type => :json, :accept => :json
      end

      ###############
      ### PROCESS DEFINITION
      ###############

      def getProcessDefinitions
        result = RestClient.get @uri + @base_path + '/process-definition', :content_type => :json, :accept => :json

        JSON.parse(result)
      end

      def createProcessInstance processDefinitionId
        url = @base_path + '/process-definition/' + processDefinitionId + '/start'

        response = @conn.post do |req|
          req.url url
          req.headers['Content-Type'] = 'application/json'
          req.body = '{}'
        end

        JSON.parse(response.body)
      end

      ###############
      ### INCIDENTS
      ###############

      def getIncidents params
        query_string = generateQueryString params

        result = RestClient.get @uri + @base_path + endpointPrefix + '/incident' + query_string, :content_type => :json, :accept => :json

        JSON.parse(result)
      end

      ###############
      ### HISTORY
      ###############

      def getHistory params
        query_string = generateQueryString params

        result = RestClient.get @uri + @base_path + '/history/activity-instance' + query_string, :content_type => :json, :accept => :json

        JSON.parse(result)
      end

      private

      def endpointPrefix
        if @use_history_endpoints
          "/history" if @use_history_endpoints
        else
          ""
        end
      end

      def generateQueryString params
        query = false
        query_string = ""

        filters = ["processDefinitionId", "processInstanceId", "assignee", "name", "taskId"]

        filters.each do |filter|
          filter_sym = filter.to_sym
          if params[filter_sym]
            query_string += "?" if query == false
            query_string += "&" if query == true
            query_string += filter + "=" + params[filter_sym]

            query = true
          end
        end

        query_string = URI.encode(query_string)
      end

    end
  end
end

