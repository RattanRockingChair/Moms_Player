package com.example.moms_player;
import android.database.Cursor;
import android.provider.MediaStore;
import com.google.gson.Gson;
import io.flutter.app.FlutterActivity;
import java.util.ArrayList;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MethodHandler implements MethodChannel.MethodCallHandler
{
    private String  _channelName = "channel.momsplayer/musicfinder";
    private FlutterActivity _activity;

    public MethodHandler(FlutterActivity flutterActivity)
    {
        _activity = flutterActivity;
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result)
    {
        if (methodCall.method.equals(_channelName))
        {
            result.success(FindLocalMusic());
        }
    }

    private String FindLocalMusic()
    {
        ArrayList<Music> musicList = new ArrayList<>();
        Cursor cursor = _activity.getContentResolver().query(MediaStore.Audio.Media.EXTERNAL_CONTENT_URI, null, null, null,null);
        assert cursor != null;

        while (cursor.moveToNext())
        {
            Music item = new Music();
            item.FilePath = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA));
            item.Title = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE));
            item.Artist = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST));
            musicList.add(item);
        }

        cursor.close();
        Gson gson = new Gson();
        return gson.toJson(musicList);
    }
}
