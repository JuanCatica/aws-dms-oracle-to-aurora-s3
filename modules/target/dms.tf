# terraform state show module.dms.aws_dms_replication_subnet_group.dms
resource "aws_dms_replication_instance" "migration_instance" {
  allocated_storage           = 20
  apply_immediately           = true
  auto_minor_version_upgrade  = true
  availability_zone           = "${var.region}a"
  multi_az                    = false
  publicly_accessible         = true
  replication_instance_class  = "dms.t2.small"
  replication_instance_id     = "migration-instance-id"
  replication_subnet_group_id = aws_dms_replication_subnet_group.dms_replication_subnet_group_target.id

  tags = {
    Name    = "migration_instance"
    project = "oracle2aurora"
  }
  vpc_security_group_ids = [aws_security_group.allow_migration.id]
}

resource "aws_dms_replication_subnet_group" "dms_replication_subnet_group_target" {
  replication_subnet_group_description = "Test replication subnet group"
  replication_subnet_group_id          = "dms-replication-subnet-group-target"
  subnet_ids                           = [aws_subnet.subnet_target_a.id, aws_subnet.subnet_target_b.id]
  tags = {
    Name    = "dms_replication_subnet_group_target"
    project = "oracle2aurora"
  }
}

resource "aws_dms_endpoint" "endpoint_source" {
  endpoint_id                 = "oracle-source-db"
  endpoint_type               = "source"
  engine_name                 = "oracle"
  extra_connection_attributes = ""
  database_name               = var.source_db_name
  username                    = var.source_db_username
  password                    = var.source_db_password
  port                        = var.source_db_port
  server_name                 = var.source_db_address # El mismo endpoint
  ssl_mode                    = "none"

  tags = {
    Name    = "endpoint_source"
    project = "oracle2aurora"
  }
}

resource "aws_dms_endpoint" "endpoint_target_aurora" {
  endpoint_id                 = "postgres-target-db"
  endpoint_type               = "target"
  engine_name                 = "postgres"
  extra_connection_attributes = ""
  database_name               = aws_rds_cluster.aurora_cluster_target.database_name
  username                    = var.target_db_username
  password                    = var.target_db_password
  port                        = aws_rds_cluster.aurora_cluster_target.port
  server_name                 = aws_rds_cluster.aurora_cluster_target.endpoint
  ssl_mode                    = "none"

  tags = {
    Name    = "endpoint_target_aurora"
    project = "oracle2aurora"
  }
}

resource "aws_dms_endpoint" "endpoint_target_s3" {
  endpoint_id                 = "s3-target-storage"
  endpoint_type               = "target"
  engine_name                 = "s3"
  extra_connection_attributes = "DatePartitionEnabled=true;DatePartitionSequence=YYYYMMDDHH;DatePartitionDelimiter=SLASH"

  s3_settings {
    bucket_name             = var.target_s3_bucket_name
    bucket_folder           = ""
    data_format             = "csv"
    date_partition_enabled  = true
    service_access_role_arn = aws_iam_role.dms_access_s3_role.arn
    compression_type        = "NONE"
    csv_delimiter           = ","
    csv_row_delimiter       = "\\n"
  }

  tags = {
    Name    = "endpoint_target_s3"
    project = "oracle2aurora"
  }

  # @TO-TRY
  # @NOT-RECOMMENDED FOR HASHICORP
  # provisioner "local-exec" {
  #   command = format("aws dms modify-endpoint --endpoint-arn %s --extra-connection-attributes %s", self.endpoint_arn, join(";", [
  #     "DatePartitionEnabled=true",
  #     "DatePartitionSequence=YYYYMMDDHH",
  #     "DatePartitionDelimiter=SLASH"
  #   ]))
  # }
}

resource "aws_dms_replication_task" "replication_task_aurora" {
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.migration_instance.replication_instance_arn
  replication_task_id      = "replication-task-aurora"
  source_endpoint_arn      = aws_dms_endpoint.endpoint_source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.endpoint_target_aurora.endpoint_arn
  table_mappings = jsonencode(
    {
      rules = [
        {
          object-locator = {
            schema-name = upper("${var.source_schema_name}")
            table-name  = "%"
          }
          rule-action = "include"
          rule-id     = "1"
          rule-name   = "1"
          rule-type   = "selection"
        },
      ]
    }
  )
  replication_task_settings = jsonencode(
    {
      BeforeImageSettings = null
      ChangeProcessingDdlHandlingPolicy = {
        HandleSourceTableAltered   = true
        HandleSourceTableDropped   = true
        HandleSourceTableTruncated = true
      }
      ChangeProcessingTuning = {
        BatchApplyMemoryLimit         = 500
        BatchApplyPreserveTransaction = true
        BatchApplyTimeoutMax          = 30
        BatchApplyTimeoutMin          = 1
        BatchSplitSize                = 0
        CommitTimeout                 = 1
        MemoryKeepTime                = 60
        MemoryLimitTotal              = 1024
        MinTransactionSize            = 1000
        StatementCacheSize            = 50
      }
      CharacterSetSettings = null
      ControlTablesSettings = {
        ControlSchema                 = ""
        FullLoadExceptionTableEnabled = false
        HistoryTableEnabled           = false
        HistoryTimeslotInMinutes      = 5
        StatusTableEnabled            = false
        SuspendedTablesTableEnabled   = false
      }
      ErrorBehavior = {
        ApplyErrorDeletePolicy                      = "IGNORE_RECORD"
        ApplyErrorEscalationCount                   = 0
        ApplyErrorEscalationPolicy                  = "LOG_ERROR"
        ApplyErrorFailOnTruncationDdl               = false
        ApplyErrorInsertPolicy                      = "LOG_ERROR"
        ApplyErrorUpdatePolicy                      = "LOG_ERROR"
        DataErrorEscalationCount                    = 0
        DataErrorEscalationPolicy                   = "SUSPEND_TABLE"
        DataErrorPolicy                             = "LOG_ERROR"
        DataTruncationErrorPolicy                   = "LOG_ERROR"
        FailOnNoTablesCaptured                      = true
        FailOnTransactionConsistencyBreached        = false
        FullLoadIgnoreConflicts                     = true
        RecoverableErrorCount                       = -1
        RecoverableErrorInterval                    = 5
        RecoverableErrorStopRetryAfterThrottlingMax = true
        RecoverableErrorThrottling                  = true
        RecoverableErrorThrottlingMax               = 1800
        TableErrorEscalationCount                   = 0
        TableErrorEscalationPolicy                  = "STOP_TASK"
        TableErrorPolicy                            = "SUSPEND_TABLE"
      }
      FailTaskWhenCleanTaskResourceFailed = false
      FullLoadSettings = {
        CommitRate                      = 10000
        CreatePkAfterFullLoad           = false
        MaxFullLoadSubTasks             = 8
        StopTaskCachedChangesApplied    = false
        StopTaskCachedChangesNotApplied = false
        TargetTablePrepMode             = "DROP_AND_CREATE"
        TransactionConsistencyTimeout   = 600
      }
      Logging = {
        EnableLogging = true
        LogComponents = [
          {
            Id       = "TRANSFORMATION"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "SOURCE_UNLOAD"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "IO"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "TARGET_LOAD"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "PERFORMANCE"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "SOURCE_CAPTURE"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "SORTER"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "REST_SERVER"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "VALIDATOR_EXT"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "TARGET_APPLY"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "TASK_MANAGER"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "TABLES_MANAGER"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "METADATA_MANAGER"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "FILE_FACTORY"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "COMMON"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "ADDONS"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "DATA_STRUCTURE"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "COMMUNICATION"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
          {
            Id       = "FILE_TRANSFER"
            Severity = "LOGGER_SEVERITY_DEFAULT"
          },
        ]
      }
      LoopbackPreventionSettings = null
      PostProcessingRules        = null
      StreamBufferSettings = {
        CtrlStreamBufferSizeInMB = 5
        StreamBufferCount        = 3
        StreamBufferSizeInMB     = 8
      }
      TargetMetadata = {
        BatchApplyEnabled            = false
        FullLobMode                  = false
        InlineLobMaxSize             = 0
        LimitedSizeLobMode           = true
        LoadMaxFileSize              = 0
        LobChunkSize                 = 0
        LobMaxSize                   = 32
        ParallelApplyBufferSize      = 0
        ParallelApplyQueuesPerThread = 0
        ParallelApplyThreads         = 0
        ParallelLoadBufferSize       = 0
        ParallelLoadQueuesPerThread  = 0
        ParallelLoadThreads          = 0
        SupportLobs                  = true
        TargetSchema                 = ""
        TaskRecoveryTableEnabled     = false
      }
      ValidationSettings = {
        EnableValidation                 = true
        FailureMaxCount                  = 10000
        HandleCollationDiff              = false
        MaxKeyColumnSize                 = 8096
        PartitionSize                    = 10000
        RecordFailureDelayInMinutes      = 5
        RecordFailureDelayLimitInMinutes = 0
        RecordSuspendDelayInMinutes      = 30
        SkipLobColumns                   = false
        TableFailureMaxCount             = 1000
        ThreadCount                      = 5
        ValidationMode                   = "ROW_LEVEL"
        ValidationOnly                   = false
        ValidationPartialLobSize         = 0
        ValidationQueryCdcDelaySeconds   = 0
      }
    }
  )
  #table_mappings           = "{\"rules\":[{\"rule-type\":\"selection\",\"rule-id\":\"1\",\"rule-name\":\"1\",\"object-locator\":{\"schema-name\":\" ${var.source_schema_name}\",\"table-name\":\"%\"},\"rule-action\":\"include\"}]}"
  # replication_task_settings = "..."

  tags = {
    Name    = "replication_task_aurora"
    project = "oracle2aurora"
  }
}

resource "aws_dms_replication_task" "replication_task_s3" {
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.migration_instance.replication_instance_arn
  replication_task_id      = "replication-task-s3"
  source_endpoint_arn      = aws_dms_endpoint.endpoint_source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.endpoint_target_s3.endpoint_arn
  table_mappings = jsonencode(
    {
      rules = [
        {
          object-locator = {
            schema-name = upper("${var.source_schema_name}")
            table-name  = "%"
          }
          rule-action = "include"
          rule-id     = "1"
          rule-name   = "1"
          rule-type   = "selection"
        },
      ]
    }
  )
  replication_task_settings = jsonencode(
    {
      "TargetMetadata" : {
        "TargetSchema" : "",
        "SupportLobs" : true,
        "FullLobMode" : false,
        "LobChunkSize" : 64,
        "LimitedSizeLobMode" : true,
        "LobMaxSize" : 32,
        "InlineLobMaxSize" : 0,
        "LoadMaxFileSize" : 0,
        "ParallelLoadThreads" : 0,
        "ParallelLoadBufferSize" : 0,
        "BatchApplyEnabled" : false,
        "TaskRecoveryTableEnabled" : false,
        "ParallelLoadQueuesPerThread" : 0,
        "ParallelApplyThreads" : 0,
        "ParallelApplyBufferSize" : 0,
        "ParallelApplyQueuesPerThread" : 0
      },
      "FullLoadSettings" : {
        "CreatePkAfterFullLoad" : false,
        "StopTaskCachedChangesApplied" : false,
        "StopTaskCachedChangesNotApplied" : false,
        "MaxFullLoadSubTasks" : 8,
        "TransactionConsistencyTimeout" : 600,
        "CommitRate" : 10000
      },
      "Logging" : {
        "EnableLogging" : true,
        "LogComponents" : [
          {
            "Id" : "SOURCE_UNLOAD",
            "Severity" : "LOGGER_SEVERITY_DEFAULT"
          },
          {
            "Id" : "SOURCE_CAPTURE",
            "Severity" : "LOGGER_SEVERITY_DEFAULT"
          },
          {
            "Id" : "TARGET_LOAD",
            "Severity" : "LOGGER_SEVERITY_DEFAULT"
          },
          {
            "Id" : "TARGET_APPLY",
            "Severity" : "LOGGER_SEVERITY_DEFAULT"
          },
          {
            "Id" : "TASK_MANAGER",
            "Severity" : "LOGGER_SEVERITY_DEFAULT"
          }
        ],
        "CloudWatchLogGroup" : null,
        "CloudWatchLogStream" : null
      },
      "ControlTablesSettings" : {
        "ControlSchema" : "",
        "HistoryTimeslotInMinutes" : 5,
        "HistoryTableEnabled" : false,
        "SuspendedTablesTableEnabled" : false,
        "StatusTableEnabled" : false
      },
      "StreamBufferSettings" : {
        "StreamBufferCount" : 3,
        "StreamBufferSizeInMB" : 8,
        "CtrlStreamBufferSizeInMB" : 5
      },
      "ChangeProcessingDdlHandlingPolicy" : {
        "HandleSourceTableDropped" : true,
        "HandleSourceTableTruncated" : true,
        "HandleSourceTableAltered" : true
      },
      "ErrorBehavior" : {
        "DataErrorPolicy" : "LOG_ERROR",
        "DataTruncationErrorPolicy" : "LOG_ERROR",
        "DataErrorEscalationPolicy" : "SUSPEND_TABLE",
        "DataErrorEscalationCount" : 0,
        "TableErrorPolicy" : "SUSPEND_TABLE",
        "TableErrorEscalationPolicy" : "STOP_TASK",
        "TableErrorEscalationCount" : 0,
        "RecoverableErrorCount" : -1,
        "RecoverableErrorInterval" : 5,
        "RecoverableErrorThrottling" : true,
        "RecoverableErrorThrottlingMax" : 1800,
        "RecoverableErrorStopRetryAfterThrottlingMax" : false,
        "ApplyErrorDeletePolicy" : "IGNORE_RECORD",
        "ApplyErrorInsertPolicy" : "LOG_ERROR",
        "ApplyErrorUpdatePolicy" : "LOG_ERROR",
        "ApplyErrorEscalationPolicy" : "LOG_ERROR",
        "ApplyErrorEscalationCount" : 0,
        "ApplyErrorFailOnTruncationDdl" : false,
        "FullLoadIgnoreConflicts" : true,
        "FailOnTransactionConsistencyBreached" : false,
        "FailOnNoTablesCaptured" : false
      },
      "ChangeProcessingTuning" : {
        "BatchApplyPreserveTransaction" : true,
        "BatchApplyTimeoutMin" : 1,
        "BatchApplyTimeoutMax" : 30,
        "BatchApplyMemoryLimit" : 500,
        "BatchSplitSize" : 0,
        "MinTransactionSize" : 1000,
        "CommitTimeout" : 1,
        "MemoryLimitTotal" : 1024,
        "MemoryKeepTime" : 60,
        "StatementCacheSize" : 50
      },
      "ValidationSettings" : {
        "EnableValidation" : false,
        "ValidationMode" : "ROW_LEVEL",
        "ThreadCount" : 5,
        "FailureMaxCount" : 10000,
        "TableFailureMaxCount" : 1000,
        "HandleCollationDiff" : false,
        "ValidationOnly" : false,
        "RecordFailureDelayLimitInMinutes" : 0,
        "SkipLobColumns" : false,
        "ValidationPartialLobSize" : 0,
        "ValidationQueryCdcDelaySeconds" : 0,
        "PartitionSize" : 10000
      },
      "PostProcessingRules" : null,
      "CharacterSetSettings" : null,
      "LoopbackPreventionSettings" : null,
      "BeforeImageSettings" : null,
      "FailTaskWhenCleanTaskResourceFailed" : false
    }
  )

  tags = {
    Name    = "replication_task_s3"
    project = "oracle2aurora"
  }
}
