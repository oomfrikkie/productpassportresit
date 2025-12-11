#!/bin/bash

# Find the MQTT container name dynamically
MQTT_CONTAINER=$(docker ps --format '{{.Names}}' | grep -i 'mqtt' | head -n 1)

if [ -z "$MQTT_CONTAINER" ]; then
    echo "❌ No MQTT container found. Make sure Docker is running and compose is up."
    exit 1
fi

echo "🐋 Using MQTT container: $MQTT_CONTAINER"

TOPIC="ssm/tracking/test"

run_batch() {
    local PRODUCT_ID=$1
    local COUNT=$2

    echo
    echo "=============================="
    echo "🚀 Starting batch for product_id: $PRODUCT_ID"
    echo "=============================="
    echo

    for ((i=1; i<=COUNT; i++))
    do
        MESSAGE="{\"scanner_id\":1,\"product_id\":${PRODUCT_ID},\"material_id\":${i}}"

        echo "🔍 scan $i started (product ${PRODUCT_ID})"
        echo "📦 sending payload: $MESSAGE"

        docker exec "$MQTT_CONTAINER" mosquitto_pub \
            -t "$TOPIC" \
            -m "$MESSAGE"

        echo "✅ scan $i completed"

        if [ $i -lt $COUNT ]; then
            echo "⏳ waiting for next scan..."
            sleep 1
            echo
        fi
    done

    echo "🎉 Batch for product_id ${PRODUCT_ID} finished!"
}


# ------------------------------
# Run batch 1 → product_id = 1
# ------------------------------
run_batch 1 5

# ------------------------------
# Run batch 2 → product_id = 2
# ------------------------------
run_batch 2 5

echo
echo "🎉 All scans completed!"
