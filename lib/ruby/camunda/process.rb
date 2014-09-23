module Ruby
  module Camunda
    class Process

      def self.create client, process_definition_id
        response = client.createProcessInstance process_definition_id

        response["id"]
      end

      def initialize client, process_definition_id, process_instance_id
        @client = client
        @process_definition_id = process_definition_id
        @process_instance_id = process_instance_id

        # check if process instance is past?
        @is_past_process = check_if_process_is_past

        if @is_past_process
          @client.useHistoryEndpoints
        end
      end

      def is_past_process?
        @is_past_process
      end

      def completeTask id, json_params = '{}'
        @client.completeTask id, json_params
      end

      def getTask task_id
        task = @client.getTask task_id

        Camunda::Task.new task
      end

      def getTaskByDefinition taskDefinition
        params = Hash.new
        params[:processInstanceId] = @process_instance_id
        params[:processDefinitionId] = @process_definition_id
        params[:taskDefinitionKey] = taskDefinition

        task = @client.getTasks params

        return task[0] if task
        return nil
      end

      def getTasks
        params = Hash.new
        params[:processInstanceId] = @process_instance_id
        params[:processDefinitionId] = @process_definition_id
        tasks = @client.getTasks params

        tasks.each do |task|
          task["full_data"] = @client.getTask task["id"]
        end

        tasks
      end

      def getIncidents
        params = Hash.new
        params[:processInstanceId] = @process_instance_id
        params[:processDefinitionId] = @process_definition_id

        @client.getIncidents params
      end

      def getHistoryEntries
        params = Hash.new
        params[:processInstanceId] = @process_instance_id
        params[:processDefinitionId] = @process_definition_id

        @client.getHistory params
      end

      def getVariables
        variables = @client.getProcessInstanceVariables @process_instance_id
      end

      def getProcessInstanceId
        @process_instance_id
      end

      def getProcessDefinitionId
        @process_definition_id
      end

      private

      def check_if_process_is_past
        res = @client.getHistoryProcessInstance @process_instance_id

        is_past = false
        is_past = true if res["endTime"] != nil

        is_past
      end

    end
  end
end

