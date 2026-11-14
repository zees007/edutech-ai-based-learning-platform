from pydantic import BaseModel, Field

class AdminMetricsResponse(BaseModel):
    totalUsers: int = Field(alias="total_users")
    freeCount: int = Field(alias="free_count")
    proCount: int = Field(alias="pro_count")
    ultraCount: int = Field(alias="ultra_count")
    totalRoles: int = Field(alias="total_roles")
    tierCounts: dict[str, int] = Field(default_factory=dict, alias="tier_counts")
    tierNames: dict[str, str] = Field(default_factory=dict, alias="tier_names")

    class Config:
        populate_by_name = True
