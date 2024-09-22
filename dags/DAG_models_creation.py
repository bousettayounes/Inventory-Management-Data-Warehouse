from datetime import timedelta
from pathlib import Path
import airflow
from airflow.decorators import dag
from dbt_airflow.core.config import DbtAirflowConfig, DbtProfileConfig, DbtProjectConfig
from dbt_airflow.core.task_group import DbtTaskGroup
from dbt_airflow.operators.execution import ExecutionOperator

default_arguments = {
    "owner": "YNS",
    "start_date": airflow.utils.dates.days_ago(0),
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 0,
    "retry_delay": 0,
}

@dag(
    dag_id="dbt_models_execution",
    default_args=default_arguments,
    schedule_interval=timedelta(days=1),
    catchup=False)

def dbt_models_and_tests_execution():
    dbt_task_group = DbtTaskGroup(
        group_id='models_creation',
        dbt_project_config=DbtProjectConfig(
            project_path=Path('/opt/airflow/dbt_project'),
            manifest_path=Path('/opt/airflow/dbt_project/target/manifest.json'),
        ),
        dbt_profile_config=DbtProfileConfig(
            profiles_path=Path('/opt/airflow/profiles'),
            target='dev',
        ),
        dbt_airflow_config=DbtAirflowConfig(
            execution_operator=ExecutionOperator.BASH,
        ),
    )
    dbt_task_group 

dbt_models_and_tests_execution()