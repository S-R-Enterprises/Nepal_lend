import type { PrismaClient, User } from "../../generated/prisma/client";

export type PublicUser = {
  id: string;
  phone: string;
  name: string | null;
  role: string;
  email: string | null;
  avatarUrl: string | null;
  kycState: string;
  createdAt: string;
};

export function toUser(user: User): PublicUser {
  return {
    id: user.id,
    phone: user.phone,
    name: user.name,
    role: user.role,
    email: user.email,
    avatarUrl: user.avatarUrl,
    kycState: user.kycState,
    createdAt: user.createdAt.toISOString(),
  };
}

export const KYC_STEP_IDS = ["citizenship", "selfie", "details"] as const;
export type KycStepId = (typeof KYC_STEP_IDS)[number];

const KYC_STEP_LABELS: Record<KycStepId, string> = {
  citizenship: "Citizenship document",
  selfie: "Selfie verification",
  details: "Personal details",
};

export type KycStatus = {
  state: string;
  steps: { id: KycStepId; label: string; status: string; updatedAt: string | null }[];
};

export async function kycStatus(
  prisma: PrismaClient,
  user: User,
): Promise<KycStatus> {
  const stored = await prisma.kycStep.findMany({ where: { userId: user.id } });
  const byId = new Map(stored.map((s) => [s.step, s]));
  const steps = KYC_STEP_IDS.map((id) => {
    const row = byId.get(id);
    return {
      id,
      label: KYC_STEP_LABELS[id],
      status: row?.status ?? "Not started",
      updatedAt: row ? row.updatedAt.toISOString() : null,
    };
  });
  return { state: user.kycState, steps };
}

export async function verifyKycStep(
  prisma: PrismaClient,
  user: User,
  step: KycStepId,
): Promise<{ user: User; status: KycStatus }> {
  await prisma.kycStep.upsert({
    where: { userId_step: { userId: user.id, step } },
    create: { userId: user.id, step, status: "Approved" },
    update: { status: "Approved", updatedAt: new Date() },
  });
  const approved = await prisma.kycStep.count({
    where: { userId: user.id, status: "Approved" },
  });
  const kycState = approved >= KYC_STEP_IDS.length ? "verified" : "in_review";
  const updated = await prisma.user.update({
    where: { id: user.id },
    data: { kycState },
  });
  return { user: updated, status: await kycStatus(prisma, updated) };
}
