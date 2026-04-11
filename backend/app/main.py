from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import importlib

app = FastAPI(title="AURION Core API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Auto-discover modules
def load_modules():
    modules_path = Path(__file__).parent.parent.parent / "modules"
    for module_dir in modules_path.iterdir():
        if module_dir.is_dir():
            routes_path = module_dir / "api" / "routes.py"
            if routes_path.exists():
                try:
                    route_module = importlib.import_module(f"modules.{module_dir.name}.api.routes")
                    if hasattr(route_module, "router"):
                        app.include_router(route_module.router, prefix=f"/api/{module_dir.name}")
                        print(f"✅ Loaded module: {module_dir.name}")
                except Exception as e:
                    print(f"⚠️ Failed to load {module_dir.name}: {e}")

load_modules()

@app.get("/")
async def root():
    return {"message": "AURION is running", "status": "active"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)