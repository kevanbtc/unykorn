import { memory_store, agent_communicate } from "claude-flow-sdk";

// WaterOracleAgent: pulls data from IoT/satellite APIs and writes to WaterOracle contract.
export async function WaterOracleAgent(input) {
  const { key, value } = input; // e.g. { key: "flow:region1", value: 123 }
  await memory_store({ key: `oracle/water/${key}`, value });
  await agent_communicate({ to: "FlowAgent", message: `Oracle update ${key}=${value}` });
  return { status: "ok", key, value };
}
