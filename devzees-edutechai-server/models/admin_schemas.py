from pydantic import BaseModel, Field

class AdminMetricsResponse(BaseModel):
    totalUsers: int = Field(alias="total_users")
    freeCount: int = Field(alias="free_count")
    proCount: int = Field(alias="pro_count")
    ultraCount: int = Field(alias="ultra_count")
    totalRoles: int = Field(alias="total_roles")

    class Config:
        populate_by_name = True
