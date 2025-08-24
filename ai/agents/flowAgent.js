import { memory_store, agent_communicate } from "claude-flow-sdk";

// FlowAgent: monitors water flow, triggers settlement, and ensures compliance.
export async function FlowAgent(input) {
  const { user, usage } = input;
  await memory_store({ key: `flow/usage/${user}`, value: usage });
  await agent_communicate({ to: "ComplianceAgent", message: `Usage reported for ${user}: ${usage}` });
  return { status: "ok", user, usage };
}
