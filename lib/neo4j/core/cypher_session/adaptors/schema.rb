module Neo4j
  module Core
    class CypherSession
      module Adaptors
        module Schema
          def version(session)
            result = query(session, 'CALL dbms.components()', {}, skip_instrumentation: true)

            # BTW: community / enterprise could be retrieved via `result.first.edition`
            result.first.versions[0]
          end

          def indexes(session)
            result = query(session, 'CALL db.indexes()', {}, skip_instrumentation: true)

            result.map do |row|
              labels, property = row.description.match(/INDEX ON (?:NODE)?:([^\(]+)\(([^\)]+)\)/)[1, 2]
              labels = labels.split(/,\s*/)
              result = {type: row.type.to_sym, properties: [property.to_sym], state: row.state.to_sym, labels: labels}
              result[:label] = labels.first.to_sym unless labels.count != 1
              result
            end
          end

          def constraints(session)
            result = query(session, 'CALL db.indexes()', {}, skip_instrumentation: true)

            result.select { |row| row.type == 'node_unique_property' }.map do |row|
              label, property = row.description.match(/INDEX ON :([^\(]+)\(([^\)]+)\)/)[1, 2]
              {type: :uniqueness, label: label.to_sym, properties: [property.to_sym]}
            end
          end
        end
      end
    end
  end
end
