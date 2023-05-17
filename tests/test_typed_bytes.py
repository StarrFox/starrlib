import io

from starrlib import TypedBytes


def test_basic():
    buffer = io.BytesIO()

    typed_buffer = TypedBytes(buffer)
    typed_buffer.write_typed("u4", 123)

    typed_buffer.seek_back_typed("u4")
    value = typed_buffer.read_typed("u4")

    assert value == 123
