default.squaresurf_influxdb.fail_on_error = true

default.squaresurf_influxdb.version = :latest
default.squaresurf_influxdb.update_version = false
default.squaresurf_influxdb.client_retries = 20
default.squaresurf_influxdb.client_hosts = ['localhost']
default.squaresurf_influxdb.client_use_ssl = false

default.squaresurf_influxdb.admin_username = 'root'
default.squaresurf_influxdb.admin_password = 'root'
default.squaresurf_influxdb.admin_old_username = 'root'
default.squaresurf_influxdb.admin_old_password = 'root'

default.squaresurf_influxdb.config = {
  'bind-address' => '0.0.0.0',
  'reporting-disabled' => false,
  'logging' => {
    'level' => 'info',
    'file' => '/opt/influxdb/shared/log.txt'
  },
  'admin' => {
    'port' => 8083
  },
  'api' => {
    'port' => 8086,
    'read-timeout' => '5s'
  },
  'input_plugins' => {
    'graphite' => {
      'enabled' => false
    },
    'collectd' => {
      'enabled' => false
    },
    'udp' => {
      'enabled' => false
    },
    'udp_servers' => [
      {
        'enabled' => false
      }
    ]
  },
  'raft' => {
    'port' => 8090,
    'dir' => '/opt/influxdb/shared/data/raft',
    'debug' => false
  },
  'storage' => {
    'dir' => '/opt/influxdb/shared/data/db',
    'write-buffer-size' => 10_000,
    'default-engine' => 'rocksdb',
    'max-open-shards' => 0,
    'point-batch-size' => 100,
    'write-batch-size' => 5_000_000,
    'retention-sweep-period' => '10m',
    'engines' => {
      'leveldb' => {
        'max-open-files' => 1000,
        'lru-cache-size' => '200m'
      },
      'rocksdb' => {
        'max-open-files' => 1000,
        'lru-cache-size' => '200m'
      },
      'hyperleveldb' => {
        'max-open-files' => 1000,
        'lru-cache-size' => '200m'
      },
      'lmdb' => {
        'map-size' => '100g'
      }
    }
  },
  'cluster' => {
    'protobuf_port' => 8099,
    'protobuf_timeout' => '2s',
    'protobuf_heartbeat' => '200ms',
    'protobuf_min_backoff' => '1s',
    'protobuf_max_backoff' => '10s',
    'write-buffer-size' => 1000,
    'max-response-buffer-size' => 100,
    'concurrent-shard-query-limit' => 10
  },
  'wal' => {
    'dir' => '/opt/influxdb/shared/data/wal',
    'flush-after' => 1000,
    'bookmark-after' => 1000,
    'index-after' => 1000,
    'requests-per-logfile' => 10_000
  }
}

default.squaresurf_influxdb.benchmark_config = {
  'log_file' => 'benchmark.log',
  'output_after_count' => 10_000,
  'stats_server' => {
    'connection_string' => 'localhost:8086',
    'database' => 'reports',
    'user' => 'user',
    'password' => 'pass',
    'is_secure' => false,
    'skip_verify' => false,
    'timeout' => '10s'
  },
  'cluster_credentials' => {
    'database' => 'benchmark',
    'user' => 'paul',
    'password' => 'pass'
  },
  'load_settings' => {
    'concurrent_connections' => 100,
    'runs_per_load_definition' => 10_000
  },
  'servers' => [
    {
      'connection_string' => 'localhost:8086',
      'is_secure' => false,
      'skip_verify' => false,
      'timeout' => '10s'
    }
  ],
  'load_definitions' => [
    {
      'name' => 'write_10_series',
      'base_series_name' => 'some_series',
      'series_count' => 100,
      'write_settings' => {
        'batch_series_size' => 10,
        'batch_points_size' => 100,
        'delay_between_posts' => '0s'
      },
      'int_columns' => [
        {
          'name' => 'value',
          'max_value' => 10
        }
      ],
      'bool_columns' => [
        {
          'name' => 'some_bool'
        }
      ],
      'float_columns' => [
        {
          'name' => 'some_other_val'
        }
      ],
      'string_columns' => [
        {
          'name' => 'type',
          'values' => %w(click open view delete)
        }
      ],
      'queries' => [
        {
          'name' => 'count',
          'query_start' => 'select count(value) from ',
          'query_end' => ' where time > now() - 30s',
          'perform_every' => '10s'
        },
        {
          'name' => 'select_last_point_from_all',
          'full_query' => 'select * from /.*/ limit 1',
          'perform_every' => '5s'
        }
      ]
    }
  ]
}
